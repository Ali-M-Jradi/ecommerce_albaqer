import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../config/app_theme.dart';
import '../models/gemstone_scan_result.dart';
import '../models/product.dart';
import '../services/gemstone_scan_service.dart';
import 'product_detail_screen.dart';

class GemstoneScanScreen extends StatefulWidget {
  const GemstoneScanScreen({super.key});

  @override
  State<GemstoneScanScreen> createState() => _GemstoneScanScreenState();
}

class _GemstoneScanScreenState extends State<GemstoneScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final GemstoneScanService _scanService = GemstoneScanService();

  File? _selectedImage;
  bool _isLoading = false;
  GemstoneScanResult? _result;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _result = null; // Clear previous result
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Future<void> _scanGemstone() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _scanService.identifyGemstone(_selectedImage!);

      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Scan failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemstone Scanner'),
        backgroundColor: AppColors.info,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image picker section
              if (_selectedImage == null)
                _buildImagePickerSection()
              else
                _buildImagePreview(),

              const SizedBox(height: 20),

              // Scan button
              if (_selectedImage != null && _result == null)
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _scanGemstone,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textOnPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.search),
                  label: Text(
                    _isLoading ? 'Analyzing...' : 'Identify Gemstone',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

              // Results section
              if (_result != null) _buildResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const Icon(Icons.camera_alt, size: 80, color: AppColors.info),
            const SizedBox(height: 16),
            const Text(
              'Take a photo or select from gallery',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: AppColors.textOnPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: AppColors.textOnPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _selectedImage!,
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _selectedImage = null;
              _result = null;
            });
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Choose Different Image'),
        ),
      ],
    );
  }

  Widget _buildResults() {
    if (!_result!.success) {
      return Card(
        color: AppColors.error.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                _result!.error ?? 'Failed to identify gemstone',
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Identification card
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.diamond, color: AppColors.info, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _result!.gemstoneName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_result!.scientificName != null)
                            Text(
                              _result!.scientificName!,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _buildConfidenceBadge(),
                  ],
                ),
                const SizedBox(height: 16),
                if (_result!.description != null) ...[
                  Text(
                    _result!.description!,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_result!.properties != null) _buildProperties(),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Expert knowledge (if RAG enhanced)
        if (_result!.ragEnhanced && _result!.expertKnowledge != null)
          _buildExpertKnowledge(),

        // Care instructions
        if (_result!.careInstructions != null) _buildCareInstructions(),

        // Matching products
        if (_result!.matchingProducts != null &&
            _result!.matchingProducts!.isNotEmpty)
          _buildMatchingProducts(),
      ],
    );
  }

  Widget _buildConfidenceBadge() {
    Color color;
    IconData icon;

    switch (_result!.confidence.toLowerCase()) {
      case 'high':
        color = AppColors.success;
        icon = Icons.check_circle;
        break;
      case 'medium':
        color = AppColors.warning;
        icon = Icons.warning;
        break;
      default:
        color = AppColors.error;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            _result!.confidence,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProperties() {
    final props = _result!.properties!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Properties',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (props.color != null) _buildPropertyRow('Color', props.color!),
        if (props.cut != null) _buildPropertyRow('Cut', props.cut!),
        if (props.clarity != null) _buildPropertyRow('Clarity', props.clarity!),
        if (props.caratEstimate != null)
          _buildPropertyRow('Carat', props.caratEstimate!),
      ],
    );
  }

  Widget _buildPropertyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildExpertKnowledge() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school, color: AppColors.info),
                const SizedBox(width: 8),
                const Text(
                  'Expert Knowledge',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(_result!.expertKnowledge!.map((knowledge) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      knowledge.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      knowledge.content,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildCareInstructions() {
    return Card(
      elevation: 4,
      color: AppColors.success.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates, color: AppColors.success),
                const SizedBox(width: 8),
                const Text(
                  'Care Instructions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(_result!.careInstructions!),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchingProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Similar Products in Our Store',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ...(_result!.matchingProducts!.map((product) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: AppColors.surface,
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: AppColors.surface,
                      child: const Icon(Icons.diamond),
                    ),
              title: Text(product.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\$${product.price.toStringAsFixed(2)}'),
                  if (product.avgRating > 0)
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: AppColors.rating,
                        ),
                        const SizedBox(width: 4),
                        Text(product.avgRating.toStringAsFixed(1)),
                      ],
                    ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Convert ScanProduct to Product and navigate
                final productObj = Product(
                  id: product.id,
                  name: product.name,
                  type: 'gemstone',
                  description: product.description,
                  basePrice: product.price,
                  rating: product.avgRating,
                  totalReviews: 0,
                  quantityInStock: product.stockQuantity,
                  imageUrl: product.imageUrl,
                  isAvailable: product.stockQuantity > 0,
                  stoneType: product.stoneType,
                  stoneColor: product.color,
                  stoneCarat: product.caratWeight,
                  stoneCut: product.cutType,
                  stoneClarity: product.clarity,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetailScreen(product: productObj),
                  ),
                );
              },
            ),
          );
        }).toList()),
      ],
    );
  }
}
