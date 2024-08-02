import os
import osproc
import strutils
import parsecfg

proc getEncfsMenuPath(): string =
  let homeDir = getHomeDir()
  let configPath = homeDir / ".config.ini"
  if not fileExists(configPath):
    echo "Конфигурационный файл не найден: ", configPath
    return ""

  var config = loadConfig(configPath)
  let encfsMenuPath = config.getSectionValue("Paths", "encfs_menu")
  if encfsMenuPath.len == 0:
    echo "Путь к encfs_menu не найден в конфигурационном файле."
    return ""

  return encfsMenuPath

proc main() =
  let encfsMenuPath = getEncfsMenuPath()
  if encfsMenuPath.len == 0:
    return

  if not fileExists(encfsMenuPath):
    echo "Файл encfs_menu не найден по пути: ", encfsMenuPath
    return

  echo "Запуск encfs_menu..."
  let result = execCmd(encfsMenuPath)
  if result == 0:
    echo "encfs_menu успешно запущен."
  else:
    echo "Ошибка при запуске encfs_menu."

main()
