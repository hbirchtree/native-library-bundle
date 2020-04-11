$ASSETS = "openal", "bullet", "assimp", "squish", "glslang", "shaderc", "spirvcross", "sdl2", "openssl", "ffmpeg", "compressonator", "zlib", "lz4", "zstd", "discord-rpc"

$INSTALL_BASE_DIR = "$env:BUILD_DIR/install"

$GITHUBAPI = "$env:SOURCE_DIR/toolchain/ci/github_api.py"

function github_api($Operation, $Element, $Repo, $Item)
{
    echo " -- github_api.py $Operation $Element $Repo $Item"
    try {
        cmd /c python $GITHUBAPI --api-token "$env:GITHUB_TOKEN" $Operation $Element $Repo $Item 2> github_error.log
    } catch {
        echo $_.Exception | Format-List -Force
    }
}

$TARGET_TAG = (github_api list tag $env:APPVEYOR_REPO_NAME "^$env:APPVEYOR_REPO_COMMIT$")
$TARGET_TAG = $TARGET_TAG.split("|")[1]
cat github_error.log

if($TARGET_TAG.Length -eq 0)
{
    echo " * Unable to find tag, no deployment"
    exit
}

ForEach($a in $ASSETS)
{
    $ASSET_NAME = $a + "_" + $env:BUILDVARIANT + ".zip"
    $ASSET = "$PWD/$ASSET_NAME"

    if (-not (test-path "$INSTALL_BASE_DIR/$a" ))
    {
        continue
    }

    echo " * Packaging dependency $a as $ASSET_NAME -> $ASSET"

    pushd "$INSTALL_BASE_DIR/$a"
    7z a $ASSET "*"
    popd

    $FILENAME = ([System.IO.Path]::GetFileName($ASSET))

    github_api push asset $env:APPVEYOR_REPO_NAME + ":" + $TARGET_TAG "$ASSET_NAME"
    cat github_error.log
}
