import osproc
import strutils
import os

proc getCurrentDir(): string =
  return getAppDir()

proc isMounted(mountPoint: string): bool =
  let output = execProcess("mount")
  return output.contains(mountPoint)

proc mountEncryptedFolder() =
  let currentDir = getCurrentDir()
  let encryptedFolderPath = currentDir / "encrypted_folder"
  let decryptedFolderPath = currentDir / "decrypted_folder"

  if isMounted(decryptedFolderPath):
    echo "Папка уже смонтирована."
  else:
    echo "Монтирование зашифрованной папки..."
    let result = execCmd("encfs " & encryptedFolderPath & " " & decryptedFolderPath)
    if result == 0:
      echo "Папка успешно смонтирована."
    else:
      echo "Ошибка при монтировании папки."

proc lockFolder() =
  let currentDir = getCurrentDir()
  let decryptedFolderPath = currentDir / "decrypted_folder"

  if not isMounted(decryptedFolderPath):
    echo "Папка уже заблокирована."
  else:
    echo "Блокировка папки..."
    let result = execCmd("fusermount -u " & decryptedFolderPath)
    if result == 0:
      echo "Папка успешно заблокирована."
    else:
      echo "Ошибка при блокировке папки."

proc createPassword() =
  let currentDir = getCurrentDir()
  let keygenPath = currentDir / "decrypted_folder" / "keygen_app" / "keygennim"

  echo "Создание пароля..."
  let result = execCmd(keygenPath)
  if result == 0:
    echo "Пароль успешно создан."
  else:
    echo "Ошибка при создании пароля."

proc viewPasswords() =
  let currentDir = getCurrentDir()
  let filePath = currentDir / "decrypted_folder" / "keygen_app" / "passwords.txt"

  if fileExists(filePath):
    echo "Просмотр сохраненных паролей:"
    let passwords = readFile(filePath)
    echo passwords
  else:
    echo "Файл с паролями не найден."

proc editPasswords() =
  let currentDir = getCurrentDir()
  let filePath = currentDir / "decrypted_folder" / "keygen_app" / "passwords.txt"

  if not fileExists(filePath):
    echo "Файл с паролями не найден."
    return

  echo "Открытие файла passwords.txt в редакторе..."
  let editors = ["micro", "nano", "vim"]
  var foundEditor = false

  for editor in editors:
    if execCmd("which " & editor) == 0:
      let result = execCmd(editor & " " & filePath)
      if result == 0:
        echo "Файл успешно отредактирован."
      else:
        echo "Ошибка при открытии файла в редакторе."
      foundEditor = true
      break

  if not foundEditor:
    echo "Не найден ни один из редакторов: micro, nano, vim."

proc mainMenu() =
  while true:
    echo ""
    echo "Выберите действие:"
    echo ""
    echo "1. Монтировать зашифрованную папку"
    echo "2. Заблокировать папку"
    echo "3. Создать пароль"
    echo "4. Просмотр сохраненных паролей"
    echo "5. Редактировать пароли"
    echo "6. Выйти"
    echo ""

    let choice = readLine(stdin)

    case choice
    of "1":
      mountEncryptedFolder()
    of "2":
      lockFolder()
    of "3":
      createPassword()
    of "4":
      viewPasswords()
    of "5":
      editPasswords()
    of "6":
      echo "Выход из программы."
      break
    else:
      echo "Неверный выбор. Пожалуйста, выберите действие из списка."

mainMenu()
