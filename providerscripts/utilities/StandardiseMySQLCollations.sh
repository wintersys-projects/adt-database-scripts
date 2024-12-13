collations="`/bin/grep -o "COLLATE=.*" ${1} | /bin/grep '^[^\s]*' | /usr/bin/cut -d' ' -f1 | /bin/sed 's/;$//g' | /usr/bin/sort -u | /usr/bin/uniq`"

for collation in ${collations}
do
        /bin/sed -i "s/${collation}/COLLATE=utf8mb4_unicode_ci/g" $1
done

charsets="`/bin/grep -o "CHARSET=.* " ${1} | /usr/bin/cut -d ' ' -f1 | /usr/bin/sort -u | /usr/bin/uniq`"

for charset in ${charsets}
do
        /bin/sed -i "s/${charset}/CHARSET=utf8mb4/g" $1
done
