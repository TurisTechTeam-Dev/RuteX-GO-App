import 'package:flutter/material.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/admin_footer.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/components/admin_form_router.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/components/admin_map_explorer.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/components/admin_sidebar.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/admin_navbar.dart';
import 'package:mobile_app/features/admin_panel/data/admin_remote_datasource.dart';
import 'package:mobile_app/features/admin_panel/data/models/admin_models.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final AdminRemoteDataSource _dataSource = AdminRemoteDataSource();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AdminNavTab? _currentTab;
  dynamic _itemToEdit;
  int _formResetVersion = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF5F5F0),
          drawer: isCompact && _currentTab != null
              ? Drawer(
                  width: constraints.maxWidth.clamp(280.0, 360.0),
                  child: AdminSidebar(
                    key: ValueKey(_currentTab),
                    currentTab: _currentTab!,
                    onItemSelected: (item) {
                      Navigator.of(context).maybePop();
                      _selectItem(item);
                    },
                  ),
                )
              : null,
          body: Column(
            children: [
              AdminNavbar(
                activeTab: _currentTab,
                onMenuPressed: isCompact && _currentTab != null
                    ? () => _scaffoldKey.currentState?.openDrawer()
                    : null,
                onTabChanged: (tab) {
                  setState(() {
                    _currentTab = tab;
                    _itemToEdit = null;
                    _formResetVersion++;
                  });
                },
              ),
              Expanded(
                child: isCompact ? _buildCompactBody() : _buildDesktopBody(),
              ),
              if (!isCompact) const AdminFooter(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentTab != null)
          Container(
            width: 340,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: AdminSidebar(
              key: ValueKey(_currentTab),
              currentTab: _currentTab!,
              onItemSelected: _selectItem,
            ),
          ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildRightPanel(isCompact: false),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildRightPanel(isCompact: true),
    );
  }

  Widget _buildRightPanel({required bool isCompact}) {
    final tab = _currentTab;
    if (tab == null) {
      return Container(
        key: const ValueKey('welcome_map'),
        child: AdminMapExplorer(dataSource: _dataSource),
      );
    }

    return Container(
      key: ValueKey(
        'form_${tab.index}_${_itemToEdit?.id ?? 'new'}_$_formResetVersion',
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 24,
        vertical: isCompact ? 12 : 20,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isCompact ? 860 : 820),
          child: Column(
            children: [
              _AdminFormHeader(
                title: _titleForTab(tab),
                isEditing: _itemToEdit != null,
                onNewPressed: _resetForm,
                isCompact: isCompact,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: isCompact ? 860 : 820,
                    child: AdminFormRouter(
                      tab: tab,
                      itemToEdit: _itemToEdit,
                      dataSource: _dataSource,
                      onItemSelected: _selectItem,
                      onSave: (data, saveFn) async {
                        try {
                          await saveFn(data);
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Guardado con éxito'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _resetForm();
                        } catch (error) {
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $error'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      onResetSelection: _resetForm,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectItem(dynamic item) {
    setState(() {
      _itemToEdit = item;

      if (item is AdminCityModel) {
        _currentTab = AdminNavTab.cities;
      }
      if (item is AdminRouteModel) {
        _currentTab = AdminNavTab.routes;
      }
      if (item is AdminPoiModel) {
        _currentTab = AdminNavTab.pointsOfInterest;
      }
      if (item is AdminMissionModel) {
        _currentTab = AdminNavTab.missions;
      }
    });
  }

  void _resetForm() {
    setState(() {
      _itemToEdit = null;
      _formResetVersion++;
    });
  }

  String _titleForTab(AdminNavTab tab) {
    switch (tab) {
      case AdminNavTab.cities:
        return 'Ciudades';
      case AdminNavTab.routes:
        return 'Rutas';
      case AdminNavTab.pointsOfInterest:
        return 'Puntos de interés';
      case AdminNavTab.missions:
        return 'Misiones';
    }
  }
}

class _AdminFormHeader extends StatelessWidget {
  final String title;
  final bool isEditing;
  final bool isCompact;
  final VoidCallback onNewPressed;

  const _AdminFormHeader({
    required this.title,
    required this.isEditing,
    required this.onNewPressed,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final titleWidget = Text(
      isEditing ? 'Editando $title' : 'Nuevo registro: $title',
      style: TextStyle(
        fontSize: isCompact ? 18 : 22,
        fontWeight: FontWeight.w700,
      ),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titleWidget,
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onNewPressed,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo / limpiar'),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: titleWidget),
        OutlinedButton.icon(
          onPressed: onNewPressed,
          icon: const Icon(Icons.add),
          label: const Text('Nuevo / limpiar'),
        ),
      ],
    );
  }
}
