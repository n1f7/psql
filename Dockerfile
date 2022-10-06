FROM gentoo/stage3:amd64-nomultilib-openrc AS build
RUN mkdir /etc/portage/repos.conf && cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf && emerge --sync
COPY make.conf /etc/portage/make.conf
RUN USE="-doc -ldap -llvm -lz4 -perl -selinux nls -ssl -tcl threads -uuid -xml -zstd -zlib -server" emerge -vN glibc ncurses sys-libs/readline postgresql
FROM scratch
COPY --from=build /usr/lib64/postgresql-14/lib64/libpq.so.5		/usr/lib64/postgresql-14/lib64/
COPY --from=build /usr/lib64/postgresql-14/bin/psql			/usr/lib64/postgresql-14/bin/
COPY --from=build /lib64/ld-linux-x86-64.so.2				/lib64/
COPY --from=build /lib64/libreadline.so.8				/lib64/
COPY --from=build /lib64/libm.so.6					/lib64/
COPY --from=build /lib64/libc.so.6					/lib64/
COPY --from=build /lib64/libtinfow.so.6					/lib64/
ENTRYPOINT ["/usr/lib64/postgresql-14/bin/psql"]
CMD ["-h", "nas.nostromo.shemyakin.me", "-p", "5433", "-U", "postgres"]