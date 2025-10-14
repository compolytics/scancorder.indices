#!/usr/bin/env python3
"""
XML MathML to PNG Converter with SymPy

This script reads XML files containing MathML formulas and generates PNG images
showing the mathematical formula with variable descriptions.
Uses SymPy for robust MathML to LaTeX conversion.

Usage: python mathml_converter.py <path_to_xml_folder>

Requirements: pip install sympy matplotlib
"""

import sympy as sp
from sympy import symbols, latex, sqrt, Integer, Float, Symbol, Abs, Function, Mul, Add, Pow, Rational


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
            expr = self._convert_to_sympy(mathml_element)
            if expr is not None:
                latex_str = latex(expr)
                latex_str = self._fix_variable_names(latex_str)
                return latex_str
            else:
                return ""
        except Exception as e:
            print(f"Warning: Failed to convert MathML to LaTeX: {e}")
            return ""
    
    def convert_to_sympy_string(self, mathml_element) -> str:
        """Convert MathML element to SymPy expression string."""
        if mathml_element is None:
            return ""
        
        try:
            # Convert MathML to SymPy expression
            expr = self._convert_to_sympy(mathml_element)
            
            if expr is not None:
                # Convert SymPy expression to string
                return str(expr)
            else:
                return ""
                
        except Exception as e:
            print(f"Warning: Failed to convert MathML to SymPy string: {e}")
            return ""
    
    def _convert_to_sympy(self, elem):
        """Recursively convert MathML elements to SymPy expressions, without simplification."""
        if elem is None:
            return None

        tag = elem.tag.split('}')[-1] if '}' in elem.tag else elem.tag
        
        if tag == 'math':
            children = list(elem)
            if children:
                return self._convert_to_sympy(children[0])
            return None
        
        elif tag == 'apply':
            children = list(elem)
            if len(children) < 2:
                return None
            operation = children[0].tag.split('}')[-1] if '}' in children[0].tag else children[0].tag
            operands = children[1:]
            sympy_operands = []
            for operand in operands:
                converted = self._convert_to_sympy(operand)
                if converted is not None:
                    sympy_operands.append(converted)
            if not sympy_operands:
                return None
            if operation == 'divide' and len(sympy_operands) == 2:
                return Mul(sympy_operands[0], Pow(sympy_operands[1], -1, evaluate=False), evaluate=False)
            elif operation == 'times':
                return Mul(*sympy_operands, evaluate=False)
            elif operation == 'plus':
                return Add(*sympy_operands, evaluate=False)
            elif operation == 'minus':
                if len(sympy_operands) == 1:
                    return Mul(-1, sympy_operands[0], evaluate=False)
                else:
                    first = sympy_operands[0]
                    rest = [Mul(-1, op, evaluate=False) for op in sympy_operands[1:]]
                    return Add(first, *rest, evaluate=False)
            elif operation == 'power' and len(sympy_operands) == 2:
                return Pow(sympy_operands[0], sympy_operands[1], evaluate=False)
            elif operation == 'root':
                if len(sympy_operands) == 1:
                    return Pow(sympy_operands[0], Rational(1, 2), evaluate=False)
                elif len(sympy_operands) == 2:
                    return Pow(sympy_operands[0], Pow(sympy_operands[1], -1, evaluate=False), evaluate=False)
            elif operation == "abs":
                return Abs(sympy_operands[0], evaluate=False)
            elif operation == 'ln':
                return sp.log(sympy_operands[0], evaluate=False)
            elif operation == "csymbol":
                csymbol_elem = children[0]
                csymbol_value = csymbol_elem.text.strip() if csymbol_elem.text else ''
                CustomFunc = Function(csymbol_value)
                return CustomFunc(*sympy_operands, evaluate=False)
        elif tag == 'ci':
            text = elem.text.strip() if elem.text else ''
            if not text:
                return None
            if text not in self.variables:
                try:
                    self.variables[text] = Symbol(text)
                except:
                    safe_name = text.replace(':', '_colon_').replace('-', '_dash_')
                    self.variables[text] = Symbol(safe_name)
            return self.variables[text]
        elif tag == 'cn':
            text = elem.text.strip() if elem.text else '0'
            try:
                if '.' in text:
                    return Float(text)
                else:
                    return Integer(text)
            except:
                return Float(0)
        elif tag == 'mi':
            text = elem.text.strip() if elem.text else ''
            if text:
                return Symbol(text)
        elif tag == 'mn':
            text = elem.text.strip() if elem.text else '0'
            try:
                if '.' in text:
                    return Float(text)
                else:
                    return Integer(text)
            except:
                return Float(0)
        children = list(elem)
        if len(children) == 1:
            return self._convert_to_sympy(children[0])
        return None
    
    def _fix_variable_names(self, latex_str: str) -> str:
        """Post-process LaTeX to fix variable names with special characters."""
        for original_name, symbol in self.variables.items():
            symbol_str = str(symbol)
            if symbol_str in latex_str and symbol_str != original_name:
                if ':' in original_name:
                    latex_str = latex_str.replace(symbol_str, f"\\text{{{original_name}}}")
                else:
                    latex_str = latex_str.replace(symbol_str, original_name)
        return latex_str