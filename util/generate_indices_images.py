#!/usr/bin/env python3
"""
XML Spectral Index to PNG Image Generator

This script reads XML files containing spectral index definitions and generates
PNG images showing the mathematical formula and variable descriptions.

Usage: python generate_indices_images.py <path_to_xml_folder>

Requirements: pip install sympy matplotlib
"""

import os
import sys
import xml.etree.ElementTree as ET
import matplotlib.pyplot as plt
from pathlib import Path
from typing import List, Dict
from mathml_converter import MathMLConverter

class SpectralIndexProcessor:
    """Processes spectral index XML files and generates PNG images."""
    def __init__(self):
        self.mathml_converter = MathMLConverter()

    def parse_xml_file(self, xml_file_path: Path) -> Dict:
        """Parse XML file and extract relevant information."""
        try:
            tree = ET.parse(xml_file_path)
            root = tree.getroot()
            name = self._get_text(root.find('Name'), 'Unknown')
            description = self._get_text(root.find('Metadata/Description'), '')
            bands_info = self._extract_bands(root.find('Wavelengths'))
            mathml_element = self._find_mathml_element(root)
            latex_formula = self.mathml_converter.convert_to_latex(mathml_element)
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
        return element.text.strip() if element is not None and element.text else default

    def _extract_bands(self, wavelengths_element) -> List[str]:
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
        try:
            mathml = root.find('MathML/{http://www.w3.org/1998/Math/MathML}math')
            if mathml is not None:
                return mathml
        except:
            pass
        return None

    def create_formula_image(self, xml_data: Dict, output_path: Path, error_message: str = None):
        plt.rcParams['figure.dpi'] = 300
        plt.rcParams['savefig.dpi'] = 300
        plt.rcParams['text.usetex'] = False
        fig, ax = plt.subplots(figsize=(14, 10))
        ax.set_xlim(0, 10)
        ax.set_ylim(0, 8)
        ax.axis('off')
        if error_message:
            ax.text(5, 6, "Error Processing XML", ha='center', va='center', fontsize=22, color='red', fontweight='bold')
            error_lines = self._wrap_text(error_message, 60)
            error_text = '\n'.join(error_lines)
            ax.text(5, 4, error_text, ha='center', va='center', fontsize=14, color='black', bbox=dict(boxstyle="round,pad=1.0", facecolor="mistyrose", alpha=0.9, edgecolor='red', linewidth=2))
            border = plt.Rectangle((0.1, 0.1), 9.8, 7.8, linewidth=3, edgecolor='red', facecolor='none', alpha=0.7)
            ax.add_patch(border)
            plt.savefig(output_path, dpi=300, bbox_inches='tight', facecolor='white', edgecolor='none', pad_inches=0.3)
            plt.close()
            print(f"✗ Error image generated: {output_path.name}")
            return
        title = f"{xml_data['name']} Index"
        ax.text(5, 7.2, title, ha='center', va='center', fontsize=20, fontweight='bold', color='darkblue')
        try:
            formula_text = f"${xml_data['latex_formula']}$"
            ax.text(5, 5.5, formula_text, ha='center', va='center', fontsize=18, bbox=dict(boxstyle="round,pad=0.8", facecolor="lightyellow", alpha=0.9, edgecolor='orange', linewidth=2))
            print(f"  Formula: {xml_data['latex_formula']}")
        except Exception as e:
            print(f"  Warning: LaTeX rendering failed, using plain text: {e}")
            formula_text = xml_data['latex_formula'].replace('\\text{', '').replace('}', '')
            formula_text = formula_text.replace('\\frac{', '(').replace('}{', ')/(')
            formula_text = formula_text.replace('\\sqrt{', 'sqrt(').replace('}', ')')
            ax.text(5, 5.5, formula_text, ha='center', va='center', fontsize=16, bbox=dict(boxstyle="round,pad=0.8", facecolor="lightyellow", alpha=0.9, edgecolor='orange', linewidth=2))
        if xml_data['description']:
            desc_lines = self._wrap_text(xml_data['description'], 60)
            desc_text = '\n'.join(desc_lines)
            ax.text(5, 4.0, desc_text, ha='center', va='center', fontsize=12, style='italic', color='darkgreen', bbox=dict(boxstyle="round,pad=0.5", facecolor="lightgreen", alpha=0.4, edgecolor='green', linewidth=1))
        if xml_data['bands_info']:
            variables_title = "Wavelength Bands:"
            variables_text = '\n'.join(xml_data['bands_info'])
            full_variables_text = f"{variables_title}\n{variables_text}"
            ax.text(5, 2.2, full_variables_text, ha='center', va='center', fontsize=11, bbox=dict(boxstyle="round,pad=0.6", facecolor="lightblue", alpha=0.8, edgecolor='blue', linewidth=1))
        border = plt.Rectangle((0.1, 0.1), 9.8, 7.8, linewidth=3, edgecolor='navy', facecolor='none', alpha=0.7)
        ax.add_patch(border)
        corner_size = 0.3
        for x, y in [(0.1, 0.1), (9.9, 0.1), (0.1, 7.9), (9.9, 7.9)]:
            corner = plt.Circle((x, y), corner_size/2, color='navy', alpha=0.3)
            ax.add_patch(corner)
        plt.savefig(output_path, dpi=300, bbox_inches='tight', facecolor='white', edgecolor='none', pad_inches=0.3)
        plt.close()
        print(f"✓ Generated: {output_path.name}")

    def _wrap_text(self, text: str, width: int) -> List[str]:
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
    if len(sys.argv) != 2:
        print("Usage: python generate_indices_images.py <path_to_xml_folder>")
        print("\nExample: python generate_indices_images.py ./spectral_indices/")
        print("\nRequirements:")
        print("  pip install sympy matplotlib")
        sys.exit(1)
    xml_folder_path = sys.argv[1]
    xml_path = Path(xml_folder_path)
    try:
        import sympy
        import matplotlib
    except ImportError as e:
        print(f"❌ Missing dependency: {e}")
        print("Please install: pip install sympy matplotlib")
        sys.exit(1)
    if not xml_path.exists():
        print(f"❌ Error: Directory '{xml_folder_path}' does not exist")
        sys.exit(1)
    if not xml_path.is_dir():
        print(f"❌ Error: '{xml_folder_path}' is not a directory")
        sys.exit(1)
    images_dir = Path("images")
    images_dir.mkdir(exist_ok=True)
    print(f"📁 Created/using images directory: {images_dir.absolute()}")
    xml_files = list(xml_path.glob("*.xml"))
    if not xml_files:
        print(f"❌ No XML files found in '{xml_folder_path}'")
        sys.exit(1)
    print(f"📄 Found {len(xml_files)} XML files")
    processor = SpectralIndexProcessor()
    success_count = 0
    error_count = 0
    for xml_file in xml_files:
        print(f"\n🔄 Processing: {xml_file.name}")
        output_path = images_dir / f"{xml_file.stem}.png"
        try:
            xml_data = processor.parse_xml_file(xml_file)
            processor.create_formula_image(xml_data, output_path)
            success_count += 1
        except Exception as e:
            print(f"❌ Error processing {xml_file.name}: {e}")
            processor.create_formula_image({}, output_path, error_message=str(e))
            error_count += 1
    print(f"\n{'='*60}")
    print(f"✅ Successfully processed: {success_count} files")
    if error_count > 0:
        print(f"❌ Errors: {error_count} files")
    print(f"📁 Images saved to: {images_dir.absolute()}")
    print(f"🔧 Using SymPy for MathML → LaTeX conversion")
    print(f"{'='*60}")

if __name__ == "__main__":
    main()
