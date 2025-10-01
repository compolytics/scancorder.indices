#!/usr/bin/env python3
"""
XML Spectral Index to Excel Table Generator

This script reads all XML files containing spectral index definitions and generates
an Excel table with columns for VIs Name, Abbreviation Algorithm, Wavelengths used, 
and Algorithm formula.

Usage: python generate_indices_table.py <path_to_xml_folder> [output_file.xlsx]

Requirements: pip install sympy pandas openpyxl
"""

import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Dict
import pandas as pd
from mathml_converter import MathMLConverter


class SpectralIndexTableGenerator:
    """Generates Excel table from spectral index XML files."""
    
    def __init__(self):
        self.mathml_converter = MathMLConverter()
    
    def parse_xml_file(self, xml_file_path: Path) -> Dict:
        """Parse XML file and extract relevant information for the table."""
        try:
            tree = ET.parse(xml_file_path)
            root = tree.getroot()
            
            # Extract VIs Name (Description)
            vis_name = self._get_text(root.find('Metadata/Description'), 'Unknown')
            
            # Extract Abbreviation Algorithm (Name)
            abbreviation = self._get_text(root.find('Name'), 'Unknown')
            
            # Extract wavelengths
            wavelengths_str = self._extract_wavelengths_formatted(root.find('Wavelengths'))
            
            # Extract and convert MathML to SymPy string
            mathml_element = self._find_mathml_element(root)
            algorithm_formula = self.mathml_converter.convert_to_sympy_string(mathml_element)
            
            # Fallback to abbreviation if no formula found
            if not algorithm_formula:
                algorithm_formula = abbreviation
            
            return {
                'vis_name': vis_name,
                'abbreviation': abbreviation,
                'wavelengths': wavelengths_str,
                'algorithm': algorithm_formula
            }
        
        except ET.ParseError as e:
            raise ValueError(f"Error parsing XML: {e}")
        except Exception as e:
            raise ValueError(f"Error processing XML file: {e}")
    
    def _get_text(self, element, default: str = '') -> str:
        """Safely extract text from XML element."""
        return element.text.strip() if element is not None and element.text else default
    
    def _extract_wavelengths_formatted(self, wavelengths_element) -> str:
        """Extract and format wavelength information as specified."""
        if wavelengths_element is None:
            return ""
        
        single_wavelengths = []
        ranges = []
        
        for band in wavelengths_element.findall('Band'):
            min_wl = band.get('min', '')
            max_wl = band.get('max', '')
            
            if min_wl and max_wl:
                try:
                    min_val = float(min_wl)
                    max_val = float(max_wl)
                    
                    if min_val == max_val:
                        # Single wavelength
                        single_wavelengths.append(min_val)
                    else:
                        # Range
                        ranges.append((min_val, max_val))
                except ValueError:
                    continue
        
        # Sort single wavelengths and ranges
        single_wavelengths.sort()
        ranges.sort(key=lambda x: x[0])  # Sort by minimum value
        
        # Format output
        result_parts = []
        
        # Add single wavelengths first
        for wl in single_wavelengths:
            if wl == int(wl):
                result_parts.append(str(int(wl)))
            else:
                result_parts.append(str(wl))
        
        # Add ranges
        for min_wl, max_wl in ranges:
            if min_wl == int(min_wl):
                min_str = str(int(min_wl))
            else:
                min_str = str(min_wl)
            
            if max_wl == int(max_wl):
                max_str = str(int(max_wl))
            else:
                max_str = str(max_wl)
            
            result_parts.append(f"{min_str}:{max_str}")
        
        return ", ".join(result_parts)
    
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
    
    def generate_excel_table(self, xml_folder_path: Path, output_file: Path = None):
        """Generate Excel table from all XML files in the folder."""
        if output_file is None:
            output_file = Path("spectral_indices_table.xlsx")
        
        # Find all XML files
        xml_files = list(xml_folder_path.glob("*.xml"))
        if not xml_files:
            raise ValueError(f"No XML files found in '{xml_folder_path}'")
        
        print(f"📄 Found {len(xml_files)} XML files")
        
        # Process all files
        table_data = []
        success_count = 0
        error_count = 0
        
        for xml_file in xml_files:
            try:
                print(f"🔄 Processing: {xml_file.name}")
                xml_data = self.parse_xml_file(xml_file)
                table_data.append({
                    'VIs Name': xml_data['vis_name'],
                    'Abbreviation Algorithm': xml_data['abbreviation'],
                    'Wavelengths used': xml_data['wavelengths'],
                    'Algorithm': xml_data['algorithm']
                })
                success_count += 1
            except Exception as e:
                print(f"❌ Error processing {xml_file.name}: {e}")
                error_count += 1
                # Add error entry to maintain complete records
                table_data.append({
                    'VIs Name': f"Error: {xml_file.stem}",
                    'Abbreviation Algorithm': xml_file.stem.upper(),
                    'Wavelengths used': "",
                    'Algorithm': f"Error: {str(e)}"
                })
        
        # Create DataFrame and sort by Abbreviation Algorithm
        df = pd.DataFrame(table_data)
        df = df.sort_values('Abbreviation Algorithm')
        
        # Save to Excel
        df.to_excel(output_file, index=False, engine='openpyxl')
        
        # Summary
        print(f"\n{'='*60}")
        print(f"✅ Successfully processed: {success_count} files")
        if error_count > 0:
            print(f"❌ Errors: {error_count} files")
        print(f"📊 Excel table saved to: {output_file.absolute()}")
        print(f"📋 Total records: {len(table_data)}")
        print(f"{'='*60}")
        
        return df


def main():
    """Main function to generate Excel table from XML files."""
    if len(sys.argv) < 2:
        print("Usage: python generate_indices_table.py <path_to_xml_folder> [output_file.xlsx]")
        print("\nExample: python generate_indices_table.py ../inst/extdata/indices/")
        print("\nRequirements:")
        print("  pip install sympy pandas openpyxl")
        sys.exit(1)
    
    xml_folder_path = sys.argv[1]
    xml_path = Path(xml_folder_path)
    
    # Optional output file
    output_file = None
    if len(sys.argv) >= 3:
        output_file = Path(sys.argv[2])
    
    # Check dependencies
    try:
        import sympy
        import pandas
        import openpyxl
    except ImportError as e:
        print(f"❌ Missing dependency: {e}")
        print("Please install: pip install sympy pandas openpyxl")
        sys.exit(1)
    
    # Validate input directory
    if not xml_path.exists():
        print(f"❌ Error: Directory '{xml_folder_path}' does not exist")
        sys.exit(1)
    
    if not xml_path.is_dir():
        print(f"❌ Error: '{xml_folder_path}' is not a directory")
        sys.exit(1)
    
    # Generate table
    generator = SpectralIndexTableGenerator()
    try:
        df = generator.generate_excel_table(xml_path, output_file)
        print(f"\n📈 Preview of generated table:")
        print(df.head().to_string())
    except Exception as e:
        print(f"❌ Failed to generate Excel table: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()