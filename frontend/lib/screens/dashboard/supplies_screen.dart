import 'package:flutter/material.dart';

class SuppliesScreen extends StatelessWidget {
  final List<SupplyItem> supplies = [
    SupplyItem(
        name: 'Hollow Blocks', 
        imagePath: 'assets/images/Hollow Blocks.jpg', 
        additionalImages: ['assets/images/Hollow Blocks_1.jpg', 'assets/images/Hollow Blocks_2.jpg', 'assets/images/Hollow Blocks_3.jpg',]),
    SupplyItem(name: 'Rebar', 
               imagePath: 'assets/images/Rebar.jpg', 
               additionalImages: ['assets/images/Rebar_1.jpg', 'assets/images/Rebar_2.jpg', 'assets/images/Rebar_3.jpg',]),
    SupplyItem(
        name: 'Sack of Cement', 
        imagePath: 'assets/images/Sack of Cement.jpg', 
        additionalImages: ['assets/images/Sack of Cement_1.jpg', 'assets/images/Sack of Cement_2.jpg', 'assets/images/Sack of Cement_3.jpg',]),
    SupplyItem(
        name: 'Sack of Bistay Sand',
        imagePath: 'assets/images/Sack of Bistay Sand.jpg', 
        additionalImages: ['assets/images/Sack of Bistay Sand_1.jpg', 'assets/images/Sack of Bistay Sand_2.jpg', 'assets/images/Sack of Bistay Sand_3.jpg']),
    SupplyItem(
        name: 'Sack of Gravel', 
        imagePath: 'assets/images/Sack of Gravel.jpg', 
        additionalImages: ['assets/images/Sack of Gravel_1.jpg', 'assets/images/Sack of Gravel_2.jpg', 'assets/images/Sack of Gravel_3.jpg']),
    SupplyItem(
        name: 'Sack of Skim Coat',
        imagePath: 'assets/images/Sack of Skim Coat.jpg', 
        additionalImages: ['assets/images/Sack of Skim Coat_1.jpg', 'assets/images/Sack of Skim Coat_2.jpg', 'assets/images/Sack of Skim Coat_3.jpg']),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('List of Supplies'),
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); 
          },
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/tectags_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Dim layer
          Container(
            color: Colors.black.withOpacity(0.5),
          ),

          // Foreground content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: supplies.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final item = supplies[index];
                return SupplyCard(item: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SupplyItem {
  final String name;
  final String imagePath;
  final List<String> additionalImages;

  SupplyItem({
    required this.name,
    required this.imagePath,
    required this.additionalImages,
  });
}


class SupplyCard extends StatelessWidget {
  final SupplyItem item;

  const SupplyCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
          builder: (_) => AdditionalImagesModal(images: item.additionalImages),
        );
      }, 
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      item.imagePath,
                      fit: BoxFit.cover,
                    ),
                    // Gradient overlay for better contrast
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black
                    .withOpacity(0.6), // dark background behind text
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Text(
                item.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black87,
                      offset: Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdditionalImagesModal extends StatelessWidget {
  final List<String> images;

  const AdditionalImagesModal({required this.images});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title bar with close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Additional Images',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            // Horizontal image list
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        images[index],
                        fit: BoxFit.cover,
                        width: 200,
                        height: 200,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
