MATCH (n:Product)
RETURN n
LIMIT 25

MATCH (n:Product)<-[r:SUPPLIES]-(s:Supplier)
RETURN n,r,s
LIMIT 25

MATCH path=(c:Customer)-[:PURCHASED]->()-[:ORDERS]->(:Product)<-[:SUPPLIES]-(:Supplier)
WHERE c.companyName = 'Blauer See Delikatessen'
RETURN path;