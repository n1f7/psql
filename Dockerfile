FROM gentoo/stage3:amd64-nomultilib-openrc AS build
COPY make.conf /etc/portage/make.conf
RUN mkdir /etc/portage/repos.conf && cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf && emerge --sync && emerge -1v portage
RUN echo en_GB.UTF-8 UTF-8 > /etc/locale.gen && locale-gen && eselect locale set en_GB.utf8
RUN USE="minimal -doc -ldap -llvm -lz4 -perl -selinux nls -ssl -tcl threads -uuid -xml -zstd -zlib -server" emerge -vN sys-libs/readline ncurses postgresql strace

FROM scratch AS app
COPY --from=build /etc/inputrc /etc/ld.so.cache																					/etc/
COPY --from=build /lib64/ld-linux-x86-64.so.2 /lib64/libreadline.so.8 /lib64/libm.so.6 /lib64/libc.so.6	/lib64/libtinfow.so.6	/lib64/
COPY --from=build /usr/lib64/postgresql-15/lib64/libpq.so.5																		/usr/lib64/postgresql-15/lib64/
COPY --from=build /usr/lib64/postgresql-15/bin/psql																				/usr/lib64/postgresql-15/bin/
COPY --from=build /usr/lib/locale/locale-archive																				/usr/lib/locale/
ENV LANG=en_GB.utf8
ENTRYPOINT ["/usr/lib64/postgresql-15/bin/psql"]
CMD ["-h", "nas.nostromo.shemyakin.me", "-p", "5433", "-U", "postgres"]

FROM app AS dev
COPY --from=build /bin/bash /bin/ls /bin/cat									/bin/
COPY --from=build /usr/bin/strace /usr/bin/env /usr/bin/locale /usr/bin/file	/usr/bin/
COPY --from=build /lib64/libtinfo.so.6											/lib64/
COPY --from=build /etc/bash/bashrc												/etc/bash/
COPY --from=build /usr/share/locale												/usr/share/locale/
COPY --from=build /etc/terminfo													/etc/terminfo/
COPY --from=build /usr/share/terminfo											/usr/share/terminfo/
ENV TERM=xterm-256color
ENTRYPOINT [ "/bin/bash" ]