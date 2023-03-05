#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Docker Mass Push
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 👨‍💻
# @raycast.packageName Docker Mass Push
# @raycast.argument1 { "type": "text", "placeholder": "imageGrep" }
# @raycast.argument2 { "type": "text", "placeholder": "destinationRegistry" }

# Documentation:
# @raycast.author Kerim Doruk Akinci
# @raycast.authorURL https://github.com/dorukakinci
# @raycast.description Push all docker images that matches the filter to the destination registry

old_registry=$1
new_registry=$2

# get all docker images
docker_images=$(docker images --format "{{.Repository}}:{{.Tag}}")

# remove unnecessary lines
docker_images=$(echo "$docker_images" | grep $old_registry)

# convert to array
docker_images_array=($docker_images)


# loop through array
for docker_image in "${docker_images_array[@]}"
do
    # split image name and tag
    IFS=':' read -ra docker_image_split <<< "$docker_image"
    docker_image_fullname=${docker_image_split[0]}
    docker_image_name=${docker_image_fullname##*/}
    docker_image_tag=${docker_image_split[1]}

    # push image
    echo "FN: $docker_image_fullname N: $docker_image_name T: $docker_image_tag --> New tag: $new_registry/$docker_image_name:$docker_image_tag"
    docker tag $docker_image_fullname:$docker_image_tag $new_registry/$docker_image_name:$docker_image_tag
    docker push $new_registry/$docker_image_name:$docker_image_tag
done