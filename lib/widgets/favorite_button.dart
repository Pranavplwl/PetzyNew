import 'package:flutter/material.dart';
import 'package:petzy/providers/favorites_provider.dart';
import 'package:provider/provider.dart';

class FavoriteButton extends StatefulWidget {
  final String petId;
  final double size;
  final Color? color;
  final Color? inactiveColor;

  const FavoriteButton({
    super.key,
    required this.petId,
    this.size = 30,
    this.color = Colors.red,
    this.inactiveColor = Colors.grey,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final favoritesProvider =
        Provider.of<FavoritesProvider>(context, listen: true);
    final isFavorite = favoritesProvider.isFavorite(widget.petId);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return IconButton(
      iconSize: widget.size,
      icon: _isProcessing
          ? SizedBox(
              width: widget.size,
              height: widget.size,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                    isFavorite ? widget.color! : widget.inactiveColor!),
              ),
            )
          : Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? widget.color : widget.inactiveColor,
            ),
      onPressed: () async {
        if (_isProcessing || !mounted) return;

        setState(() => _isProcessing = true);
        try {
          await favoritesProvider.toggleFavorite(widget.petId);
        } catch (e) {
          if (!mounted) return;
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } finally {
          if (mounted) {
            setState(() => _isProcessing = false);
          }
        }
      },
    );
  }
}
