# select * from metadatavalue where resource_type_id=3;
# ->
# ...
# 3793700;5;64;"xmlui.ssoar.labels.stock.recension";"";0;"";-1;3
# 3793701;4;64;"xmlui.ssoar.labels.stock.collection";"";0;"";-1;3
# 3793702;3;64;"xmlui.ssoar.labels.stock.incollection";"";0;"";-1;3
# 3793703;2;64;"xmlui.ssoar.labels.stock.monograph";"";0;"";-1;3
# 3793704;7;64;"xmlui.ssoar.labels.stock.discussion.editor";"";0;"";-1;3
# 3793705;6;64;"xmlui.ssoar.labels.stock.discussion.author";"";0;"";-1;3
# 3793706;1;64;"xmlui.ssoar.labels.stock.article";"";0;"";-1;3
# ...


update metadatavalue set text_value = 'Rezension' where text_value = 'xmlui.ssoar.labels.stock.recension';
update metadatavalue set text_value = 'Sammelwerk, Herausgeberband oder Konferenzband' where text_value = 'xmlui.ssoar.labels.stock.collection';
update metadatavalue set text_value = 'Beitrag in einem Sammelwerk, Herausgeberband oder Konferenzband' where text_value = 'xmlui.ssoar.labels.stock.incollection';
update metadatavalue set text_value = 'Monografie' where text_value = 'xmlui.ssoar.labels.stock.monograph';
update metadatavalue set text_value = 'Discussion Paper, Forschungsbericht, etc. (Herausgeberband)' where text_value = 'xmlui.ssoar.labels.stock.discussion.editor';
update metadatavalue set text_value = 'Discussion Paper, Forschungsbericht, etc. (Autorenband)' where text_value = 'xmlui.ssoar.labels.stock.discussion.author';
update metadatavalue set text_value = 'Beitrag in einer Zeitschrift' where text_value = 'xmlui.ssoar.labels.stock.article';
