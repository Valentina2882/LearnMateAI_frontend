import 'package:flutter/material.dart';

class CarreraSearchDropdown extends StatefulWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final bool hasError;

  const CarreraSearchDropdown({
    super.key,
    this.value,
    required this.onChanged,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.hasError = false,
  });

  @override
  State<CarreraSearchDropdown> createState() => _CarreraSearchDropdownState();
}

class _CarreraSearchDropdownState extends State<CarreraSearchDropdown> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCarreras = [];
  bool _isOpen = false;

  final List<String> _carreras = [
    'Ingeniería de Software',
    'Medicina',
  ];

  @override
  void initState() {
    super.initState();
    _filteredCarreras = _carreras;
    if (widget.value != null && widget.value!.isNotEmpty) {
      _searchController.text = widget.value!;
    }
  }

  @override
  void didUpdateWidget(CarreraSearchDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _searchController.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCarreras(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCarreras = _carreras;
      } else {
        _filteredCarreras = _carreras
            .where((carrera) =>
                carrera.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Campo de búsqueda
        TextFormField(
          controller: _searchController,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: widget.labelText ?? 'Carrera',
            hintText: widget.hintText ?? 'Busca tu carrera...',
            labelStyle: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
            ),
            prefixIcon: Icon(
              widget.prefixIcon ?? Icons.school_rounded,
              color: Colors.white70,
              size: 16,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: Colors.white70,
                size: 18,
              ),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  _isOpen = !_isOpen;
                });
              },
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide(
                color: widget.hasError 
                    ? const Color.fromARGB(255, 255, 100, 88)
                    : Colors.white.withOpacity(0.15),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide(
                color: widget.hasError 
                    ? const Color.fromARGB(255, 255, 100, 88)
                    : Colors.white.withOpacity(0.15), 
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide(
                color: widget.hasError 
                    ? const Color.fromARGB(255, 255, 100, 88)
                    : Colors.purple, 
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 255, 100, 88),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 255, 100, 88),
                width: 1.5,
              ),
            ),
            errorStyle: const TextStyle(
              color: Color.fromARGB(255, 255, 100, 88),
              fontSize: 9,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: (value) {
            _filterCarreras(value);
            widget.onChanged(value.isEmpty ? null : value);
          },
          onTap: () {
            setState(() {
              _isOpen = true;
            });
          },
        ),
        
        // Lista de carreras filtradas
        if (_isOpen && _filteredCarreras.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2634),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 150),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _filteredCarreras.length,
              itemBuilder: (context, index) {
                final carrera = _filteredCarreras[index];
                return Container(
                  decoration: BoxDecoration(
                    border: index < _filteredCarreras.length - 1 
                        ? Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08)))
                        : null,
                  ),
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    title: Text(
                      carrera,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    hoverColor: Colors.white.withOpacity(0.08),
                    onTap: () {
                      setState(() {
                        _searchController.text = carrera;
                        _isOpen = false;
                      });
                      widget.onChanged(carrera);
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
