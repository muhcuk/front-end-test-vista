import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'models.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AppState>().loadCompanies(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista Companies'),
        actions: [
          IconButton(
            onPressed: state.isLoading
                ? null
                : () => context.read<AppState>().loadCompanies(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh companies',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: context.read<AppState>().loadCompanies,
        child: _CompanyListBody(state: state),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateCompanyScreen()),
        ),
        icon: const Icon(Icons.add_business),
        label: const Text('Add company'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateServiceScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Create a service'),
          ),
        ),
      ),
    );
  }
}

class _CompanyListBody extends StatelessWidget {
  const _CompanyListBody({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.companies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.companies.isEmpty) {
      return _MessageState(
        message: state.errorMessage!,
        action: () => context.read<AppState>().loadCompanies(),
      );
    }
    if (state.companies.isEmpty) {
      return const _MessageState(
        message: 'No companies yet. Add your first one.',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        Text(
          'Your companies',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          '${state.companies.length} registered ${state.companies.length == 1 ? 'company' : 'companies'}',
          style: TextStyle(color: Colors.blueGrey.shade600),
        ),
        const SizedBox(height: 20),
        ...state.companies.map((company) => _CompanyCard(company: company)),
      ],
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.company});
  final Company company;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFD8F3EF),
                  foregroundColor: const Color(0xFF0F766E),
                  child: Text(company.name.substring(0, 1).toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Registration: ${company.registrationNumber}',
                        style: TextStyle(color: Colors.blueGrey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            Text(
              'Services (${company.services.length})',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (company.services.isEmpty)
              Text(
                'No services registered',
                style: TextStyle(color: Colors.blueGrey.shade500),
              )
            else
              ...company.services.map(
                (service) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(service.name),
                  subtitle: Text(
                    service.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '\$${service.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CreateCompanyScreen extends StatefulWidget {
  const CreateCompanyScreen({super.key});

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _registrationController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _registrationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      await context.read<AppState>().addCompany(
        name: _nameController.text.trim(),
        registrationNumber: _registrationController.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) _showError(error.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) => _FormScaffold(
    title: 'Create company',
    formKey: _formKey,
    isSaving: _isSaving,
    onSubmit: _submit,
    children: [
      TextFormField(
        controller: _nameController,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Company name',
          hintText: 'e.g. Vista Technologies',
        ),
        validator: _required,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _registrationController,
        decoration: const InputDecoration(
          labelText: 'Registration number',
          hintText: 'e.g. REG-001',
        ),
        validator: _required,
      ),
    ],
  );
}

class CreateServiceScreen extends StatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String? _companyId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AppState>().companies.isEmpty) {
        context.read<AppState>().loadCompanies();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await context.read<AppState>().addService(
        companyId: _companyId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final companies = context.watch<AppState>().companies;
    return _FormScaffold(
      title: 'Create service',
      formKey: _formKey,
      isSaving: _isSaving,
      onSubmit: _submit,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _companyId,
          decoration: const InputDecoration(labelText: 'Company'),
          items: companies
              .map(
                (company) => DropdownMenuItem(
                  value: company.id,
                  child: Text(company.name),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _companyId = value),
          validator: (value) => value == null ? 'Select a company' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Service name'),
          validator: _required,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Description'),
          validator: _required,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Price',
            prefixText: '\$ ',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Price is required';
            }
            if (double.tryParse(value.trim()) == null ||
                double.parse(value.trim()) < 0) {
              return 'Enter a valid non-negative number';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class _FormScaffold extends StatelessWidget {
  const _FormScaffold({
    required this.title,
    required this.formKey,
    required this.children,
    required this.onSubmit,
    required this.isSaving,
  });
  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final VoidCallback onSubmit;
  final bool isSaving;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete the details below to add it to your workspace.',
            style: TextStyle(color: Colors.blueGrey.shade600),
          ),
          const SizedBox(height: 28),
          ...children,
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: isSaving ? null : onSubmit,
            child: isSaving
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, this.action});
  final String message;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 52,
            color: Colors.blueGrey.shade300,
          ),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(onPressed: action, child: const Text('Try again')),
          ],
        ],
      ),
    ),
  );
}

String? _required(String? value) =>
    value == null || value.trim().isEmpty ? 'This field is required' : null;
