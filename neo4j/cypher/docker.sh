docker pull neo4j

docker run \
    --name neo \
    -d \
    --publish=7474:7474 --publish=7687:7687 \
    --volume=$HOME/neo4j/data:/data \
    --env=NEO4J_AUTH=none \
    neo4j

# neo4j/neo4j

