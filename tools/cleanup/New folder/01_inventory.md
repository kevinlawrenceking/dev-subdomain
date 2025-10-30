Goal: Inventory all /qry includes and map to target CRUD services.

Steps Claude should run:
1) rg -n --iglob '*.cfm' --iglob '*.cfc' 'include.*?/qry/([^"]+)\.cfm' > tools/cleanup/qry_usage.txt
2) Parse into CSV with columns: legacy_qry, call_file, line
3) Propose target <resourceService>.<method> for each legacy_qry using naming rules.md
4) Output mapping to tools/cleanup/qry_map.csv
5) Open PR with map + plan
