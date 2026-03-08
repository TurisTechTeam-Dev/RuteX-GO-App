import 'package:flutter/material.dart';
import 'package:mobile_app/core/routes/app_routes.dart';
import '../../../core/widgets/Bars/toppAppBarr.dart';
import '../../../core/widgets/qr_scanner/scanner_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/usescases/mission_uses_cases.dart';
import '../data/mission_repository_impl.dart';

class MisionScannerScreen extends StatefulWidget{
  const MisionScannerScreen({super.key});

  @override
  State<MisionScannerScreen> createState() => _MisionScannerScreenState();
}

class _MisionScannerScreenState extends State<MisionScannerScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MissionUseCases _useCases = MissionUseCases(MissionRepositoryImpl());
  bool _isProcessing = false;

  void _onQrCodeDetected(String code) async{
    if(_isProcessing) return;
    setState(() => _isProcessing = true);

    final result = await _useCases.executeScan(code);

    if(result != null && mounted){
      Navigator.pushNamed(context, AppRoutes.monumentInfo, arguments: result);
    } else if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("QR Code not Recognized"),
            backgroundColor: AppColors.error
        ),
      );
    }
    if(mounted) setState(() => _isProcessing = false);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Asignamos la llave para el Drawer
      drawer: const CustomDrawer(), // Tu widget genérico
      backgroundColor: Colors.black, // Cambiado a negro para que la cámara luzca mejor
      body: Stack(
        children: [
          // 1. Capa de fondo: Escáner
          RutexScannerWidget(
            onCodeDetected: (code) => _onQrCodeDetected(code),
          ),

          // 2. Capa superior: UI
          _buildOverlayUI(),
        ],
      ),
    );
  }

  Widget _buildOverlayUI() {
    return Column(
      children: [
        // Usamos Theme para que el icono de hamburguesa sea blanco (sobre la cámara)
        Theme(
          data: Theme.of(context).copyWith(
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          child: TopAppBar(
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(Icons.flash_off, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Indicador de carga si está procesando el QR
        if (_isProcessing)
          const CircularProgressIndicator(color: AppColors.verdePrincipal),

        const Spacer(),


        _buildBottomBar(),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      width: double.infinity,
      height: 90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Center(
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.verdePrincipal,
            size: 35,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}