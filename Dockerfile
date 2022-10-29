FROM gentoo/stage3:amd64-nomultilib-openrc AS build
RUN mkdir /etc/portage/repos.conf && cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf && emerge-webrsync && emaint sync -a
COPY make.conf /etc/portage/make.conf
RUN touch /root/.psql_history && USE="minimal -doc -ldap -llvm -lz4 -perl -selinux nls -ssl -tcl threads -uuid -xml -zstd -zlib -server" emerge -vN sys-libs/readline ncurses postgresql
FROM scratch
COPY --from=build /etc/inputrc						/etc/
COPY --from=build /etc/ld.so.cache					/etc/
COPY --from=build /etc/postgresql-15/psqlrc				/etc/postgresql-15/
COPY --from=build /lib64/ld-linux-x86-64.so.2				/lib64/
COPY --from=build /lib64/libreadline.so.8				/lib64/
COPY --from=build /lib64/libm.so.6					/lib64/
COPY --from=build /lib64/libc.so.6					/lib64/
COPY --from=build /lib64/libtinfow.so.6					/lib64/
COPY --from=build /usr/lib64/postgresql-15/lib64/libpq.so.5		/usr/lib64/postgresql-15/lib64/
COPY --from=build /usr/lib64/postgresql-15/bin/psql			/usr/lib64/postgresql-15/bin/
VOLUME /root/.psql_history
ENTRYPOINT ["/usr/lib64/postgresql-15/bin/psql"]
CMD ["-h", "nas.nostromo.shemyakin.me", "-p", "5433", "-U", "postgres"]