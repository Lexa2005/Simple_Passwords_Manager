# installer1.nim
import os
import osproc
import strutils

proc setupEncryptedFolder(currentDir: string) =
  let encryptedFolderPath = currentDir / "encrypted_folder"
  let decryptedFolderPath = currentDir / "decrypted_folder"

  # Проверка наличия папок перед монтированием
  if not dirExists(encryptedFolderPath):
    createDir(encryptedFolderPath)
  if not dirExists(decryptedFolderPath):
    createDir(decryptedFolderPath)

  let mountCmd = "encfs " & encryptedFolderPath & " " & decryptedFolderPath
  echo "Executing command: ", mountCmd
  let mountResult = execCmd(mountCmd)
  if mountResult != 0:
    echo "Ошибка при настройке зашифрованной папки."
  else:
    echo "Зашифрованная папка успешно настроена."

proc main() =
  let currentDir = getAppDir()
  echo "Текущая директория: ", currentDir

  setupEncryptedFolder(currentDir)

  echo "Установка завершена успешно."

main()
