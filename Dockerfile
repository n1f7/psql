FROM gentoo/stage3:amd64-nomultilib-openrc AS build
RUN mkdir /etc/portage/repos.conf && cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf && emerge-webrsync && emaint sync -a
COPY make.conf /etc/portage/make.conf
RUN USE="minimal -doc -ldap -llvm -lz4 -perl -selinux nls -ssl -tcl threads -uuid -xml -zstd -zlib -server" emerge -vN sys-libs/readline ncurses postgresql
FROM scratch
COPY --from=build /etc/terminfo/x/xterm					/etc/terminfo/x/
COPY --from=build /usr/share/terminfo					/usr/share/
COPY --from=build /etc/inputrc						/etc/
COPY --from=build /etc/passwd						/etc/passwd
COPY --from=build /etc/nsswitch.conf					/etc/
COPY --from=build /etc/postgresql-14/psqlrc				/etc/postgresql-14/
COPY --from=build /etc/ld.so.cache					/etc/
COPY --from=build /usr/lib64/postgresql-14/lib64/libpq.so.5		/usr/lib64/postgresql-14/lib64/
COPY --from=build /usr/lib64/postgresql-14/bin/psql			/usr/lib64/postgresql-14/bin/
COPY --from=build /lib64/ld-linux-x86-64.so.2				/lib64/
COPY --from=build /lib64/libreadline.so.8				/lib64/
COPY --from=build /lib64/libm.so.6					/lib64/
COPY --from=build /lib64/libc.so.6					/lib64/
COPY --from=build /lib64/libtinfow.so.6					/lib64/
ENTRYPOINT ["/usr/lib64/postgresql-14/bin/psql"]
VOLUME  /root/.psql_history
CMD ["-h", "nas.nostromo.shemyakin.me", "-p", "5433", "-U", "postgres"]