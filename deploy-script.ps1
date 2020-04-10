$ASSETS = @(openal bullet assimp squish glslang shaderc spirvcross sdl2 openssl ffmpeg compressonator zlib lz4 zstd discord-rpc)

$INSTALL_BASE_DIR = $env:BUILD_DIR/install

$GITHUBAPI = "$env:SOURCE_DIR/toolchain/ci/github_api.py"

function github_api()
{
    . python $GITHUBAPI --api-token $env:GITHUB_TOKEN $args
}

$TARGET_TAG = (github_api list tag $env:APPVEYOR_REPO_NAME "^$env:APPVEYOR_REPO_COMMIT$")
$TARGET_TAG = $TARGET_TAG.split("|")[1]

if($TARGET_TAG.Length -eq 0)
{
    echo " * Unable to find tag, no deployment"
    exit
}

ForEach($a in $ASSETS)
{
    $ASSET_NAME = "$a_$env:BUILDVARIANT.zip"
    $ASSET = "$PWD/$ASSET_NAME"

    if (-not (test-path $INSTALL_BASE_DIR/$a ))
    {
        continue
    }

    $PrevWD = $PWD
    cd $INSTALL_BASE_DIR/$a
    7z a $ASSET "*"
    cd $PrevWD

    $FILENAME = ([System.IO.Path]::GetFileName($ASSET))

    github_api push asset "$env:APPVEYOR_REPO_NAME:$TARGET_TAG" "$ASSET_NAME"
}