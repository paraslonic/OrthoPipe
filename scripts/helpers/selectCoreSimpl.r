t = read.delim("ortho_table.txt")
strains = as.numeric(system("ls ../faa/*.fasta | wc -l", intern = TRUE))
t = t[t$strains == strains, ]
write.table(t$id, "core", col.names = FALSE, row.names = FALSE, quote = FALSE)
