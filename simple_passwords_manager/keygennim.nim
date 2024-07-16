import strutils, random, os

proc generatePassword(length: int): string =
  const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+"
  var password = newString(length)
  for i in 0..<length:
    password[i] = chars[rand(chars.high)]
  return password

proc main() =
  randomize()
  
  echo "Введите длину пароля: "
  let length = parseInt(readLine(stdin))
  
  echo "Введите название сайта: "
  let site = readLine(stdin)
  
  let password = generatePassword(length)
  
  echo "Сгенерированный пароль: ", password
  
  let currentDir = getAppDir()
  let filePath = currentDir / "passwords.txt"
  let file = open(filePath, fmAppend)
  defer: file.close()
  
  file.writeLine("Сайт: " & site & ", Пароль: " & password)
  echo "Пароль успешно записан в файл passwords.txt"

main()
