"""Testes de validação de argumentos; nunca instalam pacotes ou param máquinas."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

CLI = Path(__file__).resolve().parents[1] / '.devcontainer/features/desktop-auth/pc'

class CliTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.log = self.root / 'commands.jsonl'
        self.env = {**os.environ, 'PATH': str(self.root) + ':' + os.environ['PATH'],
                    'PC_TEST_LOG': str(self.log), 'CODESPACE_NAME': 'meu-pc-1234',
                    'GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN': 'app.github.dev'}
        for name in ('apt-get', 'sudo', 'gh', 'set-resolution'):
            stub = self.root / name
            stub.write_text('#!/usr/bin/env python3\nimport os,sys,json\n'
                            'with open(os.environ["PC_TEST_LOG"],"a") as f:\n'
                            ' f.write(json.dumps(sys.argv)+"\\n")\n')
            stub.chmod(0o755)

    def run_cli(self, *args):
        return subprocess.run(['bash', str(CLI), *args], env=self.env,
                              capture_output=True, text=True)

    def commands(self):
        return [json.loads(x) for x in self.log.read_text().splitlines()] if self.log.exists() else []

    def test_url_has_no_password(self):
        result = self.run_cli('abrir')
        self.assertEqual(result.returncode, 0)
        self.assertIn('https://meu-pc-1234-6080.app.github.dev/vnc.html?', result.stdout)
        self.assertNotIn('password', result.stdout)
        self.assertFalse(self.commands())

    def test_invalid_package_arguments_never_reach_sudo(self):
        for package in ('--allow-unauthenticated', 'vlc;id', '$(id)', '../vlc', 'vlc foo', ''):
            with self.subTest(package=package):
                result = self.run_cli('instalar', package)
                self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.commands())

    def test_valid_packages_stay_separate_arguments(self):
        result = self.run_cli('instalar', 'vlc', 'libc6:amd64')
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = self.commands()
        self.assertEqual(len(calls), 2)
        self.assertEqual(calls[-1][-3:], ['--', 'vlc', 'libc6:amd64'])

    def test_resolution_bounds_and_safe_execution(self):
        for resolution in ('0x0', '9999x9999', '1280x720;id', '1x1', '640x200'):
            self.assertNotEqual(self.run_cli('resolucao', resolution).returncode, 0)
        self.assertFalse(self.commands())
        self.assertEqual(self.run_cli('resolucao', '1280x720').returncode, 0)
        self.assertEqual(self.commands()[-1][-2:], ['1280x720', '110'])

    def test_stop_is_only_explicit_and_targets_current_codespace(self):
        self.assertEqual(self.run_cli('ajuda').returncode, 0)
        self.assertFalse(self.commands())
        self.assertEqual(self.run_cli('parar').returncode, 0)
        self.assertEqual(self.commands()[-1][-4:], ['codespace', 'stop', '-c', 'meu-pc-1234'])

if __name__ == '__main__':
    unittest.main()
