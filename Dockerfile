FROM gentoo/stage3:amd64-nomultilib-openrc AS build
WORKDIR /etc/portage/repos.conf/
RUN cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf && emerge --sync
WORKDIR /
VOLUME /etc/portage/make.conf
RUN emerge -v1 portage
RUN emerge --with-bdeps=y --root /psql/ -v bash
RUN USE="-ldap -llvm -lz4 -perl  -selinux nls -ssl -tcl threads -uuid -xml -zstd -zlib -server" emerge --with-bdeps=y --root /psql/ -v postgresql
FROM scratch
COPY --from=build /psql/usr/lib64/postgresql* /usr/lib64/
COPY --from=build /psql/usr/share/locale/uk/ /usr/share/locale/
COPY --from=build /psql/usr/share/postgresql* /usr/share/
COPY --from=build /psql/lib64/libreadline* /lib64/
COPY --from=build /psql/lib64/libm* /lib64/
COPY --from=build /psql/lib64/libc* /lib64/
COPY --from=build /psql/lib64/ld-linux-x86-64* /lib64/
COPY --from=build /psql/usr/bin/psql /usr/bin/
COPY --from=build /psql/lib64/libtinfow* /lib64/
ENTRYPOINT ["/usr/bin/psql"]
CMD ["-h", "nas", "-p", "5433", "-U", "postgres"]