#!/usr/bin/env python3
"""
XML MathML to PNG Converter with SymPy

This script reads XML files containing MathML formulas and generates PNG images
showing the mathematical formula with variable descriptions.
Uses SymPy for robust MathML to LaTeX conversion.

Usage: python mathml_converter.py <path_to_xml_folder>

Requirements: pip install sympy matplotlib
"""

import os
import sys
import xml.etree.ElementTree as ET
import matplotlib.pyplot as plt
from pathlib import Path
from typing import List, Dict, Tuple
import sympy as sp
from sympy import symbols, latex, sqrt, Integer, Float, Symbol


class MathMLConverter:
    """Converts MathML elements to LaTeX strings using SymPy."""
    
    def __init__(self):
        self.namespace = {'mathml': 'http://www.w3.org/1998/Math/MathML'}
        self.variables = {}  # Keep track of created symbols for consistent naming
    
    def convert_to_latex(self, mathml_element) -> str:
        """Convert MathML element to LaTeX string using SymPy."""
        if mathml_element is None:
            return ""
        
        try:
            # Convert MathML to SymPy expression
            expr = self._convert_to_sympy(mathml_element)
            
            if expr is not None:
                # Convert SymPy expression to LaTeX
                latex_str = latex(expr)
                
                # Post-process to handle variable names with special characters
                latex_str = self._fix_variable_names(latex_str)
                
                return latex_str
            else:
                return ""
                
        except Exception as e:
            print(f"Warning: Failed to convert MathML to LaTeX: {e}")
            return ""
    
    def _convert_to_sympy(self, elem):
        """Recursively convert MathML elements to SymPy expressions."""
        if elem is None:
            return None
            
        # Remove namespace prefix for easier handling
        tag = elem.tag.split('}')[-1] if '}' in elem.tag else elem.tag
        
        if tag == 'math':
            # Root math element, process children
            children = list(elem)
            if children:
                return self._convert_to_sympy(children[0])
            return None
        
        elif tag == 'apply':
            # Mathematical operation
            children = list(elem)
            if len(children) < 2:
                return None
                
            operation = children[0].tag.split('}')[-1] if '}' in children[0].tag else children[0].tag
            operands = children[1:]
            
            # Convert all operands to SymPy expressions
            sympy_operands = []
            for operand in operands:
                converted = self._convert_to_sympy(operand)
                if converted is not None:
                    sympy_operands.append(converted)
            
            if not sympy_operands:
                return None
            
            # Handle different operations
            if operation == 'divide' and len(sympy_operands) == 2:
                return sympy_operands[0] / sympy_operands[1]
            
            elif operation == 'times':
                result = sympy_operands[0]
                for operand in sympy_operands[1:]:
                    result = result * operand
                return result
            
            elif operation == 'plus':
                result = sympy_operands[0]
                for operand in sympy_operands[1:]:
                    result = result + operand
                return result
            
            elif operation == 'minus':
                if len(sympy_operands) == 1:
                    # Unary minus
                    return -sympy_operands[0]
                else:
                    # Binary minus (subtraction)
                    result = sympy_operands[0]
                    for operand in sympy_operands[1:]:
                        result = result - operand
                    return result
            
            elif operation == 'power' and len(sympy_operands) == 2:
                return sympy_operands[0] ** sympy_operands[1]
            
            elif operation == 'root':
                # Handle square root (most common case)
                if len(sympy_operands) == 1:
                    return sqrt(sympy_operands[0])
                elif len(sympy_operands) == 2:
                    # nth root: operands[1] ** (1/operands[0])
                    # But in MathML, <root> usually means square root with one operand
                    return sqrt(sympy_operands[0])
        
        elif tag == 'ci':
            # Variable/identifier
            text = elem.text.strip() if elem.text else ''
            if not text:
                return None
                
            # Handle variables with special characters like colons
            # Store original name for later LaTeX processing
            if text not in self.variables:
                # Create SymPy symbol - SymPy can handle most characters
                try:
                    # Try to create symbol with original name
                    self.variables[text] = Symbol(text)
                except:
                    # Fallback: replace problematic characters
                    safe_name = text.replace(':', '_colon_').replace('-', '_dash_')
                    self.variables[text] = Symbol(safe_name)
            
            return self.variables[text]
        
        elif tag == 'cn':
            # Numeric constant
            text = elem.text.strip() if elem.text else '0'
            try:
                if '.' in text:
                    return Float(text)
                else:
                    return Integer(text)
            except:
                return Float(0)
        
        elif tag == 'mi':
            # Mathematical identifier (similar to ci)
            text = elem.text.strip() if elem.text else ''
            if text:
                return Symbol(text)
        
        elif tag == 'mn':
            # Mathematical number (similar to cn)
            text = elem.text.strip() if elem.text else '0'
            try:
                if '.' in text:
                    return Float(text)
                else:
                    return Integer(text)
            except:
                return Float(0)
        
        # For unhandled elements, try to process children
        children = list(elem)
        if len(children) == 1:
            return self._convert_to_sympy(children[0])
        
        return None
    
    def _fix_variable_names(self, latex_str: str) -> str:
        """Post-process LaTeX to fix variable names with special characters."""
        # Replace SymPy's handling of special characters back to original form
        for original_name, symbol in self.variables.items():
            symbol_str = str(symbol)
            if symbol_str in latex_str and symbol_str != original_name:
                # For variables with colons, render them in text mode
                if ':' in original_name:
                    latex_str = latex_str.replace(symbol_str, f"\\text{{{original_name}}}")
                else:
                    latex_str = latex_str.replace(symbol_str, original_name)
        
        return latex_str


class SpectralIndexProcessor:
    """Processes spectral index XML files and generates PNG images."""
    
    def __init__(self):
        self.mathml_converter = MathMLConverter()
    
    def parse_xml_file(self, xml_file_path: Path) -> Dict:
        """Parse XML file and extract relevant information."""
        try:
            tree = ET.parse(xml_file_path)
            root = tree.getroot()
            
            # Extract basic information
            name = self._get_text(root.find('Name'), 'Unknown')
            description = self._get_text(root.find('Metadata/Description'), '')
            
            # Extract wavelength bands
            bands_info = self._extract_bands(root.find('Wavelengths'))
            
            # Extract and convert MathML
            mathml_element = self._find_mathml_element(root)
            latex_formula = self.mathml_converter.convert_to_latex(mathml_element)
            
            # Fallback to name if no formula found
            if not latex_formula:
                latex_formula = f"\\text{{{name}}}"
            
            return {
                'name': name,
                'description': description,
                'bands_info': bands_info,
                'latex_formula': latex_formula
            }
        
        except ET.ParseError as e:
            raise ValueError(f"Error parsing XML: {e}")
        except Exception as e:
            raise ValueError(f"Error processing XML file: {e}")
    
    def _get_text(self, element, default: str = '') -> str:
        """Safely extract text from XML element."""
        return element.text.strip() if element is not None and element.text else default
    
    def _extract_bands(self, wavelengths_element) -> List[str]:
        """Extract wavelength band information."""
        bands_info = []
        if wavelengths_element is not None:
            for band in wavelengths_element.findall('Band'):
                band_name = band.get('name', 'Unknown')
                min_wl = band.get('min', '')
                max_wl = band.get('max', '')
                unit = band.get('unit', 'nm')
                
                if min_wl and max_wl:
                    if min_wl == max_wl:
                        bands_info.append(f"{band_name}: {min_wl} {unit}")
                    else:
                        bands_info.append(f"{band_name}: {min_wl}-{max_wl} {unit}")
                else:
                    bands_info.append(f"{band_name}: {unit}")
        
        return bands_info
    
    def _find_mathml_element(self, root):
        """Find MathML element in XML, handling namespaces."""
        # Try different possible paths for MathML
        mathml_paths = [
            'MathML/math',
            'MathML',
            './/math',
            './/*[local-name()="math"]'
        ]
        
        for path in mathml_paths:
            try:
                mathml = root.find(path)
                if mathml is not None:
                    return mathml
            except:
                continue
        
        # Try with explicit namespace
        try:
            mathml = root.find('MathML/{http://www.w3.org/1998/Math/MathML}math')
            if mathml is not None:
                return mathml
        except:
            pass
        
        return None
    
    def create_formula_image(self, xml_data: Dict, output_path: Path, error_message: str = None):
        """Create PNG image from XML data, or with error message if provided."""
        plt.rcParams['figure.dpi'] = 300
        plt.rcParams['savefig.dpi'] = 300
        plt.rcParams['text.usetex'] = False

        fig, ax = plt.subplots(figsize=(14, 10))
        ax.set_xlim(0, 10)
        ax.set_ylim(0, 8)
        ax.axis('off')

        if error_message:
            # Draw error image
            ax.text(5, 6, "Error Processing XML", ha='center', va='center', fontsize=22, color='red', fontweight='bold')
            # Wrap error message
            error_lines = self._wrap_text(error_message, 60)
            error_text = '\n'.join(error_lines)
            ax.text(5, 4, error_text, ha='center', va='center', fontsize=14, color='black', bbox=dict(boxstyle="round,pad=1.0", facecolor="mistyrose", alpha=0.9, edgecolor='red', linewidth=2))
            border = plt.Rectangle((0.1, 0.1), 9.8, 7.8, linewidth=3, edgecolor='red', facecolor='none', alpha=0.7)
            ax.add_patch(border)
            plt.savefig(output_path, dpi=300, bbox_inches='tight', facecolor='white', edgecolor='none', pad_inches=0.3)
            plt.close()
            print(f"✗ Error image generated: {output_path.name}")
            return

        # ...existing code for normal image generation...
        # Add title
        title = f"{xml_data['name']} Index"
        ax.text(5, 7.2, title, ha='center', va='center', 
                fontsize=20, fontweight='bold', color='darkblue')

        # Add formula
        try:
            formula_text = f"${xml_data['latex_formula']}$"
            ax.text(5, 5.5, formula_text, ha='center', va='center', fontsize=18, 
                   bbox=dict(boxstyle="round,pad=0.8", facecolor="lightyellow", 
                            alpha=0.9, edgecolor='orange', linewidth=2))
            print(f"  Formula: {xml_data['latex_formula']}")
        except Exception as e:
            print(f"  Warning: LaTeX rendering failed, using plain text: {e}")
            formula_text = xml_data['latex_formula'].replace('\\text{', '').replace('}', '')
            formula_text = formula_text.replace('\\frac{', '(').replace('}{', ')/(')
            formula_text = formula_text.replace('\\sqrt{', 'sqrt(').replace('}', ')')
            ax.text(5, 5.5, formula_text, ha='center', va='center', fontsize=16,
                   bbox=dict(boxstyle="round,pad=0.8", facecolor="lightyellow", 
                            alpha=0.9, edgecolor='orange', linewidth=2))

        if xml_data['description']:
            desc_lines = self._wrap_text(xml_data['description'], 60)
            desc_text = '\n'.join(desc_lines)
            ax.text(5, 4.0, desc_text, ha='center', va='center', 
                   fontsize=12, style='italic', color='darkgreen',
                   bbox=dict(boxstyle="round,pad=0.5", facecolor="lightgreen", 
                            alpha=0.4, edgecolor='green', linewidth=1))

        if xml_data['bands_info']:
            variables_title = "Wavelength Bands:"
            variables_text = '\n'.join(xml_data['bands_info'])
            full_variables_text = f"{variables_title}\n{variables_text}"
            ax.text(5, 2.2, full_variables_text, ha='center', va='center', fontsize=11,
                   bbox=dict(boxstyle="round,pad=0.6", facecolor="lightblue", 
                                alpha=0.8, edgecolor='blue', linewidth=1))

        border = plt.Rectangle((0.1, 0.1), 9.8, 7.8, linewidth=3, 
                              edgecolor='navy', facecolor='none', alpha=0.7)
        ax.add_patch(border)

        corner_size = 0.3
        for x, y in [(0.1, 0.1), (9.9, 0.1), (0.1, 7.9), (9.9, 7.9)]:
            corner = plt.Circle((x, y), corner_size/2, color='navy', alpha=0.3)
            ax.add_patch(corner)

        plt.savefig(output_path, dpi=300, bbox_inches='tight', 
                   facecolor='white', edgecolor='none', pad_inches=0.3)
        plt.close()
        print(f"✓ Generated: {output_path.name}")
    
    def _wrap_text(self, text: str, width: int) -> List[str]:
        """Wrap text to specified width."""
        words = text.split()
        lines = []
        current_line = []
        current_length = 0
        
        for word in words:
            if current_length + len(word) + 1 <= width:
                current_line.append(word)
                current_length += len(word) + 1
            else:
                if current_line:
                    lines.append(' '.join(current_line))
                current_line = [word]
                current_length = len(word)
        
        if current_line:
            lines.append(' '.join(current_line))
        
        return lines


def main():
    """Main function to process XML files and generate images."""
    if len(sys.argv) != 2:
        print("Usage: python mathml_converter.py <path_to_xml_folder>")
        print("\nExample: python mathml_converter.py ./spectral_indices/")
        print("\nRequirements:")
        print("  pip install sympy matplotlib")
        sys.exit(1)
    
    xml_folder_path = sys.argv[1]
    xml_path = Path(xml_folder_path)
    
    # Check dependencies
    try:
        import sympy
        import matplotlib
    except ImportError as e:
        print(f"❌ Missing dependency: {e}")
        print("Please install: pip install sympy matplotlib")
        sys.exit(1)
    
    # Validate input directory
    if not xml_path.exists():
        print(f"❌ Error: Directory '{xml_folder_path}' does not exist")
        sys.exit(1)
    
    if not xml_path.is_dir():
        print(f"❌ Error: '{xml_folder_path}' is not a directory")
        sys.exit(1)
    
    # Create images directory
    images_dir = Path("images")
    images_dir.mkdir(exist_ok=True)
    print(f"📁 Created/using images directory: {images_dir.absolute()}")
    
    # Find XML files
    xml_files = list(xml_path.glob("*.xml"))
    if not xml_files:
        print(f"❌ No XML files found in '{xml_folder_path}'")
        sys.exit(1)
    
    print(f"📄 Found {len(xml_files)} XML files")
    
    # Process files
    processor = SpectralIndexProcessor()
    success_count = 0
    error_count = 0
    
    for xml_file in xml_files:
        print(f"\n🔄 Processing: {xml_file.name}")
        output_path = images_dir / f"{xml_file.stem}.png"
        try:
            # Parse XML
            xml_data = processor.parse_xml_file(xml_file)
            # Create image
            processor.create_formula_image(xml_data, output_path)
            success_count += 1
        except Exception as e:
            print(f"❌ Error processing {xml_file.name}: {e}")
            # Generate error image
            processor.create_formula_image({}, output_path, error_message=str(e))
            error_count += 1
    
    # Summary
    print(f"\n{'='*60}")
    print(f"✅ Successfully processed: {success_count} files")
    if error_count > 0:
        print(f"❌ Errors: {error_count} files")
    print(f"📁 Images saved to: {images_dir.absolute()}")
    print(f"🔧 Using SymPy for MathML → LaTeX conversion")
    print(f"{'='*60}")


if __name__ == "__main__":
    main()