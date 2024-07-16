# installer0.nim
import os
import osproc
import strutils
import strformat  # Добавлен импорт модуля strformat

proc isEncfsInstalled(): bool =
  let checkCmd = "which encfs"
  let checkResult = execCmd(checkCmd)
  return checkResult == 0

proc isNimInstalled(): bool =
  let checkCmd = "which nim"
  let checkResult = execCmd(checkCmd)
  return checkResult == 0

proc isNimInBashrc(): bool =
  let bashrcPath = "$HOME/.bashrc"
  let checkCmd = fmt"grep 'export PATH=\$HOME/.nimble/bin:\$PATH' {bashrcPath}"
  let checkResult = execCmd(checkCmd)
  return checkResult == 0

proc installEncfs() =
  if isEncfsInstalled():
    echo "encfs уже установлен."
  else:
    echo "Установка encfs на Fedora Linux..."
    let installCmd = "sudo dnf install -y encfs"
    echo "Executing command: ", installCmd
    let installResult = execCmd(installCmd)
    if installResult != 0:
      echo "Ошибка при установке encfs."
    else:
      echo "encfs успешно установлен."

proc installNim() =
  if isNimInstalled():
    echo "Nim уже установлен."
  else:
    echo "Установка Nim..."
    let installCmd = "curl https://nim-lang.org/choosenim/init.sh -sSf | sh"
    echo "Executing command: ", installCmd
    let installResult = execCmd(installCmd)
    if installResult != 0:
      echo "Ошибка при установке Nim."
    else:
      echo "Nim успешно установлен."

proc addNimToBashrc() =
  if isNimInBashrc():
    echo "Путь к Nim уже добавлен в ~/.bashrc."
  else:
    echo "Добавление пути к Nim в ~/.bashrc..."
    let nimPath = "$HOME/.nimble/bin"
    let bashrcPath = "$HOME/.bashrc"
    let appendCmd = fmt"echo 'export PATH={nimPath}:$PATH' >> {bashrcPath}"
    echo "Executing command: ", appendCmd
    let appendResult = execCmd(appendCmd)
    if appendResult != 0:
      echo "Ошибка при добавлении пути к Nim в ~/.bashrc."
    else:
      echo "Путь к Nim успешно добавлен в ~/.bashrc."

proc main() =
  installEncfs()
  installNim()
  addNimToBashrc()

  echo "Установка завершена успешно."

main()
