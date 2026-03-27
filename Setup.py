#! /usr/bin/env python3
# coding: utf-8

#: Title       : Setup
#: Date        : 2026-03-26
#: Update      : 2026-03-27
#: Author      : Thierry Gautier <tgauti@free.fr>
#: Version     : 1.0
#: Description : checking correct installation for BIO713 module
#: Usage       : python Setup.py [script_name]


"""
Script to check the presence of required Python modules for Course BIO713 - UGA.
Prints available modules with their versions and suggests installation commands
for any missing modules.
"""

import os
import sys

# List of required modules (add/remove as needed)
REQUIRED_MODULES = ["Bio", "reportlab"]  # Example list


def title_sup():
    """
    Displays the header with some information about the script.
    """
    line = 40 * "#"
    print(line)
    print("#" + 10 * " " + "BIO 713 Setup")
    print("#" + 10 * " " + "UGA")
    print("#" + 10 * " " + "TG©2026")
    print(line)
    print("# Checks the presence of required module:")
    print("# - Biopython\n# - ReportLab")
    print(line)


def check_module(module_name):
    """
    Checks if a specific module is installed and returns its version.
    Returns a tuple: (is_installed, version_string)
    """
    try:
        # Try to import the module
        __import__(module_name)

        # Get the version from the module's metadata or direct attribute
        mod = sys.modules[module_name]
        version_info = getattr(mod, "__version__", "Unknown")

        return True, version_info
    except ImportError as e:
        return False, str(e)


def get_install_command(module_name):
    """
    Returns the standard pip command to install a specific module.
    """
    # You might want to use `pip3` instead of `pip` for your environment
    if os.name == "nt":  # Windows
        return f"pip install {module_name}"
    else:  # Linux/Mac/Unix
        return f"pixi add {module_name}"


def main():
    title_sup()
    print(f"#\n# 🔍 Checking required modules...\n#")

    all_installed = True

    for module in REQUIRED_MODULES:
        is_ok, info = check_module(module)

        if is_ok:
            print(f"# ✅ [FOUND] {module:15} version {info}")
        else:
            print(f"# ❌ [MISSING] {module:15}")
            all_installed = False
            # Optional: Print the install command immediately
            if module == "BIO":
                print(f"#       🔧 Install command: pixi add biopython\n")
            else:
                print(f"#       🔧 Install command: {get_install_command(module)}\n#")

    print("#" * 40)

    if all_installed:
        print("# ✅ All required modules are installed and ready!")
        print("#\n# End of Script")
        print("#" * 40)
        sys.exit(0)  # Success code (usually 0)
    else:
        print(
            "# ❌ Some dependencies are missing.\n#\n# Please install them before running your project."
        )
        print("#\n# End of Script")
        print("#" * 40)
        sys.exit(1)  # Error code (usually non-zero, e.g., 1)


if __name__ == "__main__":
    main()
