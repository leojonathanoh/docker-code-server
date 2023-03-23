$local:PACKAGE_NAME = 'code-server'
$local:PACKAGE_VERSION_STABLE = '4.8.3'
$local:PACKAGE_VERSIONS = @"
4.11.0
"@
# 4.10.1
# 4.9.1
# 4.8.3
# 4.7.1
# 4.6.1
$local:COMPONENTS_STABLE = @"
{
    "_": {
        level: 0
    },
    "docker": {
        level: 0
    },
    "docker-rootless": {
        level: 0
    },
    "go-1.17.13": {
        level: 1
    },
    "go-1.18.10": {
        level: 1
    },
    "go-1.19.7": {
        level: 1
    },
    "go-1.20.2": {
        level: 1
    },
    "jq": {
        level: 2
    }
}
"@
$local:COMPONENTS_UNSTABLE = @"
{
    "_": {
        level: 1
    },
    "docker": {
        level: 1
    },
    "docker-rootless": {
        level: 1
    }
}
"@
$local:OSES = @"
alpine:3.15
"@

$VARIANTS = @(
    $i = 0
    foreach ($p in $local:PACKAGE_VERSIONS -split "`n") {
        foreach ($o in $local:OSES -split "`n") {
            $components = $local:COMPONENTS_STABLE | ConvertFrom-Json -Depth 100 -AsHashtable
            $maxLevel = [int]($components.GetEnumerator() | % { $_.Value['level'] } | Sort-Object | Select-Object -Last 1)
            for ($level = 0; $level -le $maxlevel; $level++) {
                $levelKeys = $components.GetEnumerator() | ? { $_.Value['level'] -eq $level } | % { $_.Name } | Sort-Object
                $levelAllKeys = $components.GetEnumerator() | ? { ! $_.Value.Contains('level') } | % { $_.Name } | Sort-Object
                $levelHigherKeys = $components.GetEnumerator() | ? { $_.Value['level'] -eq ($level + 1) } | % { $_.Name } | Sort-Object
                "[one] level: $level" | Write-Host -ForegroundColor Green
                foreach ($lk in $levelKeys) {
                    # Matrix my level
                    # Matrix me and higher level
                    @(
                        & {
                            if ($lk -ne '_') { $lk | % { $_.Trim() } | ? { $_ } }
                        }
                    ) -join '-' | Write-Host
                }
                "[two] level: $level" | Write-Host -ForegroundColor Green
                foreach ($lk in $levelKeys) {
                    foreach($lhk in ($levelHigherKeys | ? { $_ -ne '_'})) {
                        @(
                            & {
                                if ($lk -ne '_') { $lk | % { $_.Trim() } | ? { $_ } }
                                $lhk | % { $_.Trim() } | ? { $_ }
                            }
                        ) -join '-' | Write-Host
                    }
                }
            }
        }
    }
        #     @{
        #         # Metadata object
        #         _metadata = @{
        #             package = $local:PACKAGE_NAME
        #             package_version = $p
        #             distro = $o -split ':' | Select-Object -Index 0
        #             distro_version = $o -split ':' | Select-Object -Index 1
        #             base_tag = if ($subVariant['components'].Count -eq 0) {
        #                 '' # Base image has no base
        #             }elseif ($subVariant['components'].Count -eq 1) {
        #                 # 1st incremental should point to base
        #                 @(
        #                     "v$p"
        #                     $o -split ':' | Select-Object -Index 0
        #                     $o -split ':' | Select-Object -Index 1
        #                 ) -join '-'
        #             }else {
        #                 # 2nd or greater incremental should point to prior incremental
        #                 @(
        #                     "v$p"
        #                     $subVariant['components'][0..($subVariant['components'].Count - 2)]
        #                     $o -split ':' | Select-Object -Index 0
        #                     $o -split ':' | Select-Object -Index 1
        #                 ) -join '-'
        #             }
        #             platforms = 'linux/amd64'
        #             components = $subVariant['components']
        #         }
        #         # Docker image tag. E.g. 'v2.3.0-alpine-3.6'
        #         tag = @(
        #                 "v$p"
        #                 $subVariant['components'] | ? { $_ }
        #                 $o -split ':' | Select-Object -Index 0
        #                 $o -split ':' | Select-Object -Index 1
        #         ) -join '-'
        #         tag_as_latest = if ($i -eq 0 -and $subVariant['components'].Count -eq 0) { $true } else { $false }
        #     }
        # }
        # $i++
)

# Docker image variants' definitions (shared)
$VARIANTS_SHARED = @{
    buildContextFiles = @{
        templates = @{
            'Dockerfile' = @{
                common = $true
                passes = @(
                    @{
                        variables = @{}
                    }
                )
            }
            'docker-entrypoint.sh' = @{
                common = $true
                passes = @(
                    @{
                        variables = @{}
                    }
                )
            }
            'settings.json' = @{
                common = $true
                passes = @(
                    @{
                        variables = @{}
                    }
                )
            }
        }
    }
}

# Global cache for remote file content
$global:CACHE = @{}
$VARIANTS
