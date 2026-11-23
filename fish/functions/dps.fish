function dps --description 'docker ps grouped by compose file (● running, ○ stopped), with published host ports'
    # Groups by the compose *file*, not the project: compose files that share a
    # folder (e.g. shufflecom-api's docker-compose.yml + docker-compose.e2e.yml)
    # land in one project, so `docker compose ls` can't tell them apart.
    # Containers started outside compose (e.g. testcontainers) show under "(no compose)".
    docker ps -a $argv --format '{{.Label "com.docker.compose.project.config_files"}}|{{.Names}}|{{.State}}|{{.Status}}|{{.Ports}}' \
        | sort | awk -F'|' '
        { n = split($1, p, "/"); grp = (p[n] == "" ? "(no compose)" : p[n])
          if (grp != last) { printf "%s%s\n", (NR > 1 ? "\n" : ""), grp; last = grp }
          ports = ""; s = $5
          while (match(s, /0\.0\.0\.0:[0-9]+->[0-9]+/)) {
              m = substr(s, RSTART + 8, RLENGTH - 8); ports = ports (ports ? " " : "") m
              s = substr(s, RSTART + RLENGTH) }
          printf "  %s %-22s %-14s %s\n", ($3 == "running" ? "●" : "○"), $2, $4, ports }'
end
