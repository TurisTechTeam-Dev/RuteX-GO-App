import 'package:flutter/material.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/admin_footer.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/components/admin_form_router.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/components/admin_map_explorer.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/components/admin_sidebar.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/admin_navbar.dart';
import 'package:mobile_app/features/admin_panel/domain/usecases/admin_use_cases.dart';
import 'package:mobile_app/features/admin_panel/presentation/models/admin_editable_item.dart';
import 'package:mobile_app/features/admin_panel/presentation/models/admin_form_controller.dart';
import 'package:provider/provider.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AdminFormController _formController = AdminFormController();

  AdminNavTab? _currentTab;
  AdminEditableItem? _itemToEdit;
  int _formResetVersion = 0;

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminUseCases = context.read<AdminUseCases>();

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
                    adminUseCases: adminUseCases,
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
                    _formController.reset();
                  });
                },
              ),
              Expanded(
                child: isCompact
                    ? _buildCompactBody(adminUseCases)
                    : _buildDesktopBody(adminUseCases),
              ),
              if (!isCompact) const AdminFooter(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopBody(AdminUseCases adminUseCases) {
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
              adminUseCases: adminUseCases,
              onItemSelected: _selectItem,
            ),
          ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildRightPanel(
              isCompact: false,
              adminUseCases: adminUseCases,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactBody(AdminUseCases adminUseCases) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildRightPanel(isCompact: true, adminUseCases: adminUseCases),
    );
  }

  Widget _buildRightPanel({
    required bool isCompact,
    required AdminUseCases adminUseCases,
  }) {
    final tab = _currentTab;
    if (tab == null) {
      return Container(
        key: const ValueKey('welcome_map'),
        child: const AdminMapExplorer(),
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
                formController: _formController,
                isCompact: isCompact,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _HorizontalFormScroll(
                  width: isCompact ? 860 : 820,
                  child: AdminFormRouter(
                      tab: tab,
                      itemToEdit: _itemToEdit,
                      adminUseCases: adminUseCases,
                      formController: _formController,
                      onSave: (saveItem) async {
                        try {
                          await saveItem();
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
            ],
          ),
        ),
      ),
    );
  }

  void _selectItem(AdminEditableItem? item) {
    setState(() {
      _itemToEdit = item;
      _currentTab = item?.tab ?? _currentTab;
      _formController.reset();
    });
  }

  void _resetForm() {
    setState(() {
      _itemToEdit = null;
      _formResetVersion++;
      _formController.reset();
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

class _HorizontalFormScroll extends StatefulWidget {
  final double width;
  final Widget child;

  const _HorizontalFormScroll({required this.width, required this.child});

  @override
  State<_HorizontalFormScroll> createState() => _HorizontalFormScrollState();
}

class _HorizontalFormScrollState extends State<_HorizontalFormScroll> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: widget.width, child: widget.child),
      ),
    );
  }
}

class _AdminFormHeader extends StatelessWidget {
  final String title;
  final bool isEditing;
  final bool isCompact;
  final VoidCallback onNewPressed;
  final AdminFormController formController;

  const _AdminFormHeader({
    required this.title,
    required this.isEditing,
    required this.onNewPressed,
    required this.isCompact,
    required this.formController,
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

    final actions = _HeaderActions(
      formController: formController,
      onNewPressed: onNewPressed,
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titleWidget,
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: actions,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: titleWidget),
        actions,
      ],
    );
  }
}

class _HeaderActions extends StatelessWidget {
  final AdminFormController formController;
  final VoidCallback onNewPressed;

  const _HeaderActions({
    required this.formController,
    required this.onNewPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: formController,
      builder: (context, _) {
        return Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: formController.canSave ? formController.save : null,
              icon: formController.isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(
                formController.isSaving ? 'Guardando...' : 'Guardar cambios',
              ),
            ),
            OutlinedButton.icon(
              onPressed: onNewPressed,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo / limpiar'),
            ),
          ],
        );
      },
    );
  }
}
