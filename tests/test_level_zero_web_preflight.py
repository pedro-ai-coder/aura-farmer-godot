"""Offline HTML export shell contract; does not need Godot or browser hardware."""
import importlib.util
from pathlib import Path
import unittest

SCRIPT_PATH = Path(__file__).resolve().parents[1] / 'scripts' / 'inject_level_zero_preflight.py'
spec = importlib.util.spec_from_file_location('inject_level_zero_preflight', SCRIPT_PATH)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class ExportInjectionTests(unittest.TestCase):
    def test_scripts_go_into_head_once(self):
        html = '<!doctype html><html><head><title>Godot</title></head><body><canvas id="canvas"></canvas></body></html>'
        result = module.inject(html)
        self.assertEqual(result.count(module.SCRIPT), 1)
        self.assertLess(result.index(module.SCRIPT), result.index('</head>'))
        self.assertIn('<canvas id="canvas"></canvas>', result)

    def test_rejects_unexpected_export_layout(self):
        with self.assertRaises(ValueError):
            module.inject('<body></body>')
        with self.assertRaises(ValueError):
            module.inject('<head></head><head></head>')

    def test_rejects_double_injection(self):
        with self.assertRaises(ValueError):
            module.inject(module.inject('<head></head>'))


if __name__ == '__main__':
    unittest.main()
