from __future__ import annotations

import ctypes
import json
import os
from ctypes import wintypes
from pathlib import Path

class DATA_BLOB(ctypes.Structure):
    _fields_ = [("cbData", wintypes.DWORD), ("pbData", ctypes.POINTER(ctypes.c_ubyte))]

CRYPTPROTECT_UI_FORBIDDEN = 0x1


def _blob(raw: bytes):
    buf = ctypes.create_string_buffer(raw)
    return DATA_BLOB(len(raw), ctypes.cast(buf, ctypes.POINTER(ctypes.c_ubyte))), buf


def _dpapi(raw: bytes, protect: bool) -> bytes:
    crypt = ctypes.WinDLL("Crypt32", use_last_error=True)
    kernel = ctypes.WinDLL("Kernel32", use_last_error=True)
    crypt.CryptProtectData.argtypes = [ctypes.POINTER(DATA_BLOB), wintypes.LPCWSTR, ctypes.POINTER(DATA_BLOB), wintypes.LPVOID, wintypes.LPVOID, wintypes.DWORD, ctypes.POINTER(DATA_BLOB)]
    crypt.CryptProtectData.restype = wintypes.BOOL
    crypt.CryptUnprotectData.argtypes = [ctypes.POINTER(DATA_BLOB), ctypes.POINTER(wintypes.LPWSTR), ctypes.POINTER(DATA_BLOB), wintypes.LPVOID, wintypes.LPVOID, wintypes.DWORD, ctypes.POINTER(DATA_BLOB)]
    crypt.CryptUnprotectData.restype = wintypes.BOOL
    kernel.LocalFree.argtypes = [wintypes.HLOCAL]
    kernel.LocalFree.restype = wintypes.HLOCAL
    source, keepalive = _blob(raw)
    output = DATA_BLOB()
    if protect:
        ok = crypt.CryptProtectData(ctypes.byref(source), "SpotiWoW-Dev Spotify session", None, None, None, CRYPTPROTECT_UI_FORBIDDEN, ctypes.byref(output))
    else:
        description = wintypes.LPWSTR()
        ok = crypt.CryptUnprotectData(ctypes.byref(source), ctypes.byref(description), None, None, None, CRYPTPROTECT_UI_FORBIDDEN, ctypes.byref(output))
        if description:
            kernel.LocalFree(description)
    if not ok:
        raise ctypes.WinError(ctypes.get_last_error())
    try:
        return ctypes.string_at(output.pbData, output.cbData)
    finally:
        kernel.LocalFree(output.pbData)


class TokenStore:
    """Current-user DPAPI storage; token JSON is never written in plaintext."""
    def __init__(self, path: Path):
        self.path = path

    def load(self):
        try:
            raw = _dpapi(self.path.read_bytes(), False)
            value = json.loads(raw.decode("utf-8"))
            return value if isinstance(value, dict) else None
        except (OSError, ValueError, UnicodeError, ctypes.ArgumentError):
            return None

    def save(self, value: dict) -> None:
        self.path.parent.mkdir(parents=True, exist_ok=True)
        protected = _dpapi(json.dumps(value, separators=(",", ":")).encode("utf-8"), True)
        temp = self.path.with_suffix(self.path.suffix + ".tmp")
        temp.write_bytes(protected)
        os.replace(temp, self.path)

    def delete(self) -> None:
        try:
            self.path.unlink()
        except FileNotFoundError:
            pass
