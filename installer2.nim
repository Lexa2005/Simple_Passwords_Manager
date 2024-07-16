import os
import osproc
import strutils

proc renameToHidden(filePath: string) =
  if fileExists(filePath):
    let hiddenPath = filePath.splitFile.dir / ("." & filePath.splitFile.name & filePath.splitFile.ext)
    moveFile(filePath, hiddenPath)
    echo "Скрытый файл создан: ", hiddenPath

proc copyAndCompileFiles(currentDir: string) =
  let encfsMenuPath = currentDir / "encfs_menu.nim"
  let keygenAppDir = currentDir / "decrypted_folder" / "keygen_app"
  let keygennimPath = keygenAppDir / "keygennim.nim"
  let passwordsFilePath = keygenAppDir / "passwords.txt"

  # Проверка наличия исходного файла encfs_menu.nim
  if not fileExists(encfsMenuPath):
    echo "Файл encfs_menu.nim не найден в текущей директории."
    return

  # Проверка содержимого исходного файла encfs_menu.nim
  let originalContent = readFile(encfsMenuPath)
  if originalContent.len == 0:
    echo "Исходный файл encfs_menu.nim пуст."
    return
  else:
    echo "Содержимое исходного файла encfs_menu.nim:"
    echo originalContent

  # Компиляция файла encfs_menu.nim
  echo "Компиляция encfs_menu.nim..."
  let compileEncfsMenuOutput = execProcess("nim c " & encfsMenuPath)
  echo compileEncfsMenuOutput

  # Создание директории keygen_app, если она не существует
  if not dirExists(keygenAppDir):
    createDir(keygenAppDir)

  # Копирование исходного файла keygennim.nim в decrypted_folder/keygen_app
  let sourceKeygennimPath = currentDir / "keygennim.nim"
  if not fileExists(sourceKeygennimPath):
    echo "Файл keygennim.nim не найден в текущей директории."
    return

  echo "Копирование keygennim.nim..."
  copyFile(sourceKeygennimPath, keygennimPath)

  # Проверка наличия скопированного файла keygennim.nim
  if not fileExists(keygennimPath):
    echo "Файл keygennim.nim не был скопирован в целевую директорию."
    return

  # Компиляция файла keygennim.nim
  echo "Компиляция keygennim.nim..."
  let compileKeygennimOutput = execProcess("nim c " & keygennimPath)
  echo compileKeygennimOutput

  # Проверка наличия скомпилированных файлов
  if not fileExists(encfsMenuPath.replace(".nim", "")):
    echo "Файл encfs_menu не был скомпилирован."
  if not fileExists(keygennimPath.replace(".nim", "")):
    echo "Файл keygennim не был скомпилирован."

  # Создание файла passwords.txt, если он не существует
  if not fileExists(passwordsFilePath):
    echo "Создание файла passwords.txt..."
    writeFile(passwordsFilePath, "")
    echo "Файл passwords.txt создан."

  # Скрытие файлов
  renameToHidden(currentDir / "installer1")
  renameToHidden(currentDir / "installer1.nim")
  renameToHidden(currentDir / "installer2.nim")
  renameToHidden(currentDir / "installer2")
  renameToHidden(currentDir / "keygennim.nim")
  renameToHidden(currentDir / "installer0.nim")
  renameToHidden(currentDir / "installer0")
  renameToHidden(currentDir / "encfs_menu.nim")
  renameToHidden(keygenAppDir / "keygennim.nim")

proc main() =
  let currentDir = getAppDir()
  echo "Текущая директория: ", currentDir

  copyAndCompileFiles(currentDir)

  echo "Установка завершена успешно."

main()
