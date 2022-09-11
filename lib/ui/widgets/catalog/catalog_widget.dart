import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
import '../constructor/constructor_widget.dart';
import '../preview/preview_widget.dart';
import 'catalog_model.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Catalog(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Catalog')),
        body: const _DesignsGrid(),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ConstructorScreen(),
            ),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('My Design'),
        ),
      ),
    );
  }
}

class _DesignsGrid extends StatelessWidget {
  const _DesignsGrid();

  @override
  Widget build(BuildContext context) {
    final catalogModel = context.watch<Catalog>();

    return catalogModel.isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: catalogModel.tshirts.length,
            padding: const EdgeInsets.only(bottom: 80),
            itemBuilder: (context, index) {
              final tshirt = catalogModel.tshirts.values.elementAt(index);

              return Card(
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PreviewScreen(tshirt),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(buttonsSpacing),
                    child: Column(
                      children: [
                        Expanded(
                          child: TshirtPreviewWidget(
                            tshirt: tshirt,
                          ),
                        ),
                        Text(
                          tshirt.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
}
