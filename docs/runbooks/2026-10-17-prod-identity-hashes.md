# Prod / dev file identity hashes (2026-10-17)

Compare on the server with `certutil -hashfile <path> SHA256` (lowercase the output).
HEAD columns identify an unmodified HEAD copy in either line-ending form. The working-tree
column is what a deploy of the 2026-10-17 batches must produce. A file matching none of the
three is some other version: record its hash and do not assume which.

Base commit: c7bdde78. Working tree: uncommitted 2026-10-17 state. Regenerate this table
if any listed file changes before deploy.

| File | HEAD (LF) | HEAD (CRLF) | Working tree |
|---|---|---|---|
| include/get_reminders.cfm | 5b15b43bbc5f800988adc9aa5f7e3baf3c7bca25d6ac42386eb933767224ba81 | f241803cf3e722b45c41eeecaf5d9eb4345061ca45a7a37049e688435daa8f75 | b28f47ce33d0e596bebedd6ee58d7981bd0aa1fcc2001f9fa59edfd7023acc2b |
| services/PanelUserService.cfc | 0b4bd819f6c3a655f2ec1d9856861a9dc684476951e8a45adac60a8e9738d9f3 | e40770bde66270452cda42fc8d59149a4ed9e663c6980393782ab957829f98ec | 3b183005bc2d929902d4c1471be32c4fde1395bf8927ad3927c058cb29432cd9 |
| include/dashboardupdate2.cfm | f3c62165b7cecffe8ce984a48acb583b8d4a6341fe66c1ba71178f1310379f35 | 0541e67117b7ad2944349fc5cf235682a201a9ec310a13cba3bb9fee2c12433d | 73777eac98c85e769a22100ef3dd8038fcf981e6ef2d9cd8870387ecb676b95c |
| include/icsmaker.cfm | 7dc3b6df16944a96e2121d5c1710e2fdb1474fc5794d040ec480c9d41ff67ed5 | 37cce1731fec9ba03b9acda32b2fe26a3e41d2c578e4175ee53dcab31555ef8d | a1b6d512981d88f4b66a6c0f59294bf4f2f99cb122dc015a82e290b2cfa51c2e |
| include/qry/calendar-appoint.cfm | fec2094dd3445e331ab24fe710aeb551bf48fdcc6fd19c86864f02762d93f12e | 3f3cf9791f1cd478c282bef3dd2c6620e33a11a4434aea929232217ca5f3164e | fec2094dd3445e331ab24fe710aeb551bf48fdcc6fd19c86864f02762d93f12e |
| sched/events_completed.cfm | 5f4a2e5dd1b1d3467783fa9f558716883bbb474a4a3deb9ce02c2728033fa7d8 | 3b9db0bd17a2314e358260e762920126940a864ea52c0cb547ab052cfca6c73a | e0d72f704fa973ff60623b7275ef6cbdd7d3e1bea3659f2ff752e8f37faad897 |
| services/ErrorService.cfc | 5404575153d4a91cb850644cd6743b17b76e519385c90606081067c78ca03889 | 9dd79fdc648185a6cae72f975ad62804731319a6519a16d737ed882d974f3086 | 0d805ca5b2d2f5ba52a53cc1e29a6730e43dd67fc5c2e7bcb60a6bfc9a21a813 |
| include/contact_info.cfm | be8aaa90fe80ad5b37320a3261820703943260767cb62bfd616a84c4f6196af9 | e81649ecf8898e11028ebb199bd9c2487b2a175c680707f742894ed044bdfda4 | 27b90437ee7548be7c4653ea74fb096f2d1cf0ad982e0e2ff7eb02ddcb4077d2 |
| ajax/contact/updateprimary.cfm | 9389b2156592913d699a69e8b29691ed849254d2fb54fe0f96042a41e42bea78 | e20783f236ffdc53f6686d91cc70bc8d1fcbf7b601e5f283517c7d8dea9207c8 | 60daaf8ee0fd33366a9b1b8a0492c0fae7a0f9b0476747f818a920f37acb502c |
| ajax/importv3/parse.cfm | 7c2ce144e887f9a02290b1e9520ed800265073517df8edf8eb6205e74e5b85bd | 9d6d6fdaeb9e9be852b58071628b33427ffe8b82e8ba2b32240887e99a347630 | ad355b6f4f0019643abd6c82d1f8698ae4222ba27b3b247adadff53f1307b3fd |
| app/Application.cfc | fba85db94dbaf5e28de8de2585650bd1ae3401e35470bb9d44e926e7e1de1fa9 | d512e42a8d3701f061100cf74fb314bbcd3896902e5c0817d9ef375feb9e099e | 8c643cf57e5e4622ea3005e0b6ea5e74d3aef0174d872d35375be0d69f088dcf |
| include/Application.cfc | a1cfba805783cc4656a02703cc2ac1ebd082584b224908d2d5ab6537857865da | 999eb3a93a3ef90f52321c4118cac9ef6b3c4f6181e4b9929c0e0711971fe00b | f9b68fa3b8bcbd4ff93fe435d7c1ee971da1fe0c4c368936d4ada0e7d3f7b275 |
| ajax/master/link-confirm.cfm | 2c245164aa04474d765fed02e22e1432d2b4eda1bdc0deedb5dac15a28d07b18 | 343cdb2afcbd9be083b13851be7470f58060e5b084ffa286d95f9481c3f5865c | 76a2c00590ea4d1c1c18b661628d8424168ef56c100ff7f1c1a2592322611c4d |
| ajax/master/resyncall.cfm | 0f9aba140250f9cb97d0d012d3add1a5acca0901e1698c38b91a347d6d2c65a5 | 3bc107ea0d6218518771057b373f77a76c48a01ddb84a745291c89935a79c036 | 61017633a0492e8baed3e105c17b54c9db2d1f822fb5a40054a26a83bbc2819a |
| include/master_link_preview.cfm | 855a6cd60db4808893d71f366e7fca14eea4e7fddada250402d7f44b348715ff | 95a509ef818a92077ea7082f91dbfd23e7cc8381d49b44eec5742fe7ced1d07f | 855a6cd60db4808893d71f366e7fca14eea4e7fddada250402d7f44b348715ff |
