import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../core/theme.dart';
import '../components/organisms/header.dart';
import '../components/organisms/control_panel.dart';
import '../components/organisms/game_canvas.dart';
import '../components/molecules/shop_modal.dart';
import '../components/molecules/ad_modal.dart';
import '../components/molecules/revive_modal.dart';
import '../components/molecules/account_modal.dart';
import '../components/molecules/game_modal.dart';

// Pantalla principal: arma la interfaz y muestra los modales.
// Las reglas del juego viven en GameController; acá solo se le dice qué hacer.
class GameScreen extends StatefulWidget {
  final GameController controlador;

  const GameScreen({super.key, required this.controlador});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameController get _juego => widget.controlador;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final regalo = await _juego.cargar();
    if (!mounted || regalo == 0) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.tinta,
        content: Text(
          '¡Recibiste $regalo 💎 de tu cuenta PRO!',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Future<void> _reiniciarConAnuncio() async {
    // Pausamos para que el juego no siga corriendo detrás de los modales
    _juego.pausar();

    final confirmado = await GameModal.confirmar(
      context,
      titulo: '¿Reiniciar?',
      mensaje: 'Vas a perder los ${_juego.jugador.puntaje} puntos de esta partida '
          'y volver al inicio.',
    );
    // NO: queda en pausa para que siga cuando toque REANUDAR
    if (!confirmado || !mounted) return;

    // PRO no ve publicidad; igual vuelve a la pantalla de inicio (INICIAR PARTIDA)
    if (_juego.esPro) {
      _juego.volverAlInicio();
      return;
    }
    AdModal.mostrar(
      context,
      // Al cerrar el anuncio vuelve a la pantalla de inicio (INICIAR PARTIDA)
      _juego.volverAlInicio,
      // "PRO": abre la tienda y, al cerrarla, vuelve a la pantalla de inicio
      alQuitarAnuncios: () async {
        await _abrirTienda();
        if (mounted) _juego.volverAlInicio();
      },
    );
  }

  void _alChocar() {
    if (_juego.chocar()) _ofrecerRevivir();
  }

  Future<void> _ofrecerRevivir() async {
    final eleccion = await ReviveModal.mostrar(
      context,
      puntaje: _juego.jugador.puntaje,
      diamantes: _juego.jugador.diamantes,
      costo: _juego.costoRevivir,
    );
    if (!mounted) return;

    switch (eleccion) {
      case ReviveChoice.revive:
        _juego.revivir();
      case ReviveChoice.shop:
        await _abrirTienda();
        if (mounted) _ofrecerRevivir(); // Al volver de la tienda, se vuelve a ofrecer
      case ReviveChoice.giveUp:
        _juego.terminarPartida();
    }
  }

  Future<void> _abrirTienda() {
    return ShopModal.mostrar(
      context,
      alComprarDiamantes: _juego.comprarDiamantes,
      alComprarPro: _juego.comprarPro,
      esPro: _juego.esPro,
      diamantes: _juego.jugador.diamantes,
    );
  }

  // Desde el header: si se está jugando, pausa para que el juego no siga detrás del modal
  void _abrirTiendaDesdeHeader() {
    _juego.pausarSiEstaJugando();
    _abrirTienda();
  }

  // Píldora de cuenta: PRO ve su suscripción (y puede cancelarla); BASIC va a la tienda
  void _alTocarCuenta() {
    if (!_juego.esPro) {
      _abrirTiendaDesdeHeader();
      return;
    }
    _juego.pausarSiEstaJugando();
    AccountModal.mostrar(
      context,
      proximoRegalo: _juego.proximoRegaloPro,
      alCancelarPro: _juego.cancelarPro,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Se redibuja cada vez que el controlador llama a notifyListeners()
    return ListenableBuilder(
      listenable: _juego,
      builder: (context, _) => Scaffold(
        body: Column(
          children: [
            Header(
              estadoJugador: _juego.jugador,
              alAbrirTienda: _abrirTiendaDesdeHeader,
              alTocarCuenta: _alTocarCuenta,
              alCambiarTema: _juego.alternarTema,
            ),
            Expanded(
              child: GameCanvas(
                estadoJuego: _juego.estadoJuego,
                ronda: _juego.ronda,
                vecesRevivido: _juego.vecesRevivido,
                alChocar: _alChocar,
                alSumarPuntos: _juego.sumarPuntos,
                alAgarrarDiamante: _juego.agarrarDiamante,
              ),
            ),
            ControlPanel(
              estadoJuego: _juego.estadoJuego,
              alIniciar: _juego.iniciarPartida,
              alPausar: _juego.pausar,
              alReanudar: _juego.reanudar,
              alReiniciar: _reiniciarConAnuncio,
              alNuevaPartida: _juego.iniciarPartida,
            ),
          ],
        ),
      ),
    );
  }
}
