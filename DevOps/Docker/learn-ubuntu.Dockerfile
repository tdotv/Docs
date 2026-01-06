FROM ubuntu:22.04
LABEL author=tdotv

RUN apt-get update
RUN apt-get install nginx -y
# | Команды P.S. Для удаления кэша дляя команд по установке
# | APT: ... && rm -rf /var/cache/apt
# | APK: ... && rm -rf /etc/apk/cache
# | YUM: ... && rm -rf /var/cache/yum
# | DNF: ... && rm -rf /var/cache/dnf

# !!! Важно заметить, что таким образом для скачивания nginx создается 2 слоя, вместо этого лучше использовать:
RUN apt-get update && apt-get install nginx -y \ 
    htop \
    tree \ 
    mc
# | Таким образом создаем один слой и скачиваем сразу несколько пакетов

WORKDIR /var/www/html/
# | Рабочие директории - Как бы указываем докеру в какую директорию перейти
# | . это и есть рабочая директория

COPY files2/index.html .
COPY files2/script.sh /opt/script.sh
# | Файлы - Volumes

RUN chmod +x /opt/script.sh
# | Работа с файлами. Делаем наш скрипт executable

ENV OWNER="tdotv"
ENV TYPE=demo
# | Указание переменных : -e TYPE=prod

EXPOSE 80
# | Порты (ничего не делает для образа, носит инф. контекст)

ENTRYPOINT ["echo"]
CMD ["Hello my FIRST Docker"]
# | Описание команд при запуске контейнера : CMD ["echo","Hi"] 