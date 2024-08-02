import os
import osproc
import strutils
import strformat
import parsecfg

# Функция для проверки установки encfs
proc isEncfsInstalled(): bool =
  let checkCmd = "which encfs"
  let checkResult = execCmd(checkCmd)
  return checkResult == 0

# Функция для определения дистрибутива
proc getDistro(): string =
  let distro = execProcess("lsb_release -is")
  return distro.strip()

# Функция для установки encfs в зависимости от дистрибутива
proc installEncfs() =
  let distro = getDistro()
  echo "Определен дистрибутив: ", distro

  if isEncfsInstalled():
    echo "encfs уже установлен."
  else:
    var installCmd = ""
    case distro
    of "Fedora":
      installCmd = "sudo dnf install -y encfs"
    of "Ubuntu", "Debian":
      installCmd = "sudo apt-get update && sudo apt-get install -y encfs"
    of "Arch":
      installCmd = "sudo pacman -S --noconfirm encfs"
    else:
      echo "Неизвестный дистрибутив. Установка encfs не поддерживается."
      return

    echo "Установка encfs на ", distro, "..."
    echo "Executing command: ", installCmd
    let installResult = execCmd(installCmd)
    if installResult != 0:
      echo "Ошибка при установке encfs."
    else:
      echo "encfs успешно установлен."

# Функции из installer1.nim
proc setupEncryptedFolder(currentDir: string) =
  let encryptedFolderPath = currentDir / "encrypted_folder"
  let decryptedFolderPath = currentDir / "decrypted_folder"

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

# Функции из installer2.nim
proc renameToHidden(filePath: string) =
  if fileExists(filePath):
    let hiddenPath = filePath.splitFile.dir / ("." & filePath.splitFile.name & filePath.splitFile.ext)
    moveFile(filePath, hiddenPath)
    echo "Скрытый файл создан: ", hiddenPath

proc copyAndCompileFiles(currentDir: string) =
  let encfsMenuPath = currentDir / "encfs_menu"
  let keygenAppDir = currentDir / "decrypted_folder" / "keygen_app"
  let keygennimPath = keygenAppDir / "keygennim"
  let passwordsFilePath = keygenAppDir / "passwords.txt"

  if not fileExists(encfsMenuPath):
    echo "Файл encfs_menu не найден в текущей директории."
    return

  if not dirExists(keygenAppDir):
    createDir(keygenAppDir)

  let sourceKeygennimPath = currentDir / "keygennim"
  if not fileExists(sourceKeygennimPath):
    echo "Файл keygennim не найден в текущей директории."
    return

  echo "Копирование keygennim..."
  copyFile(sourceKeygennimPath, keygennimPath)

  if not fileExists(keygennimPath):
    echo "Файл keygennim не был скопирован в целевую директорию."
    return

  echo "Установка прав на выполнение для keygennim..."
  let chmodResult = execCmd("chmod +x " & keygennimPath)
  if chmodResult != 0:
    echo "Ошибка при установке прав на выполнение для keygennim."
    return

  if not fileExists(passwordsFilePath):
    echo "Создание файла passwords.txt..."
    writeFile(passwordsFilePath, "")
    echo "Файл passwords.txt создан."

  # Создание и настройка config.ini
  let configPath = currentDir / "config.ini"
  var config = newConfig()
  config.setSectionKey("Paths", "encfs_menu", encfsMenuPath)
  config.writeConfig(configPath)
  echo "Конфигурационный файл создан: ", configPath

  # Копирование config.ini в домашнюю папку и переименование в скрытый файл
  let homeDir = getHomeDir()
  let destConfigPath = homeDir / ".config.ini"
  echo "Копирование config.ini в домашнюю папку и переименование в скрытый файл..."
  copyFile(configPath, destConfigPath)

  # Копирование spm в домашнюю папку и установка прав на выполнение
  let spmPath = currentDir / "spm"
  let destSpmPath = homeDir / "spm"

  if not fileExists(spmPath):
    echo "Файл spm не найден в текущей директории."
    return

  echo "Копирование spm в домашнюю папку..."
  copyFile(spmPath, destSpmPath)

  echo "Установка прав на выполнение для spm..."
  let chmodSpmResult = execCmd("chmod +x " & destSpmPath)
  if chmodSpmResult != 0:
    echo "Ошибка при установке прав на выполнение для spm."
    return

# Главная функция
proc main() =
  let currentDir = getAppDir()
  echo "Текущая директория: ", currentDir

  installEncfs()

  setupEncryptedFolder(currentDir)

  copyAndCompileFiles(currentDir)

  echo "Установка завершена успешно."

main()
