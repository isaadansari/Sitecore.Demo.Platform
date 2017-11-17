Param(
    [string] $ConfigurationFile = "configuration-xp0.json"
)

Write-Host "Setting Defaults and creating $ConfigurationFile"

$json = Get-Content -Raw .\install-settings.json |  ConvertFrom-Json

# Assets and prerequisites

$assets = $json.assets
$assets.root = "$PSScriptRoot\assets"
$assets.psRepository = "https://sitecore.myget.org/F/sc-powershell/api/v2/"
$assets.psRepositoryName = "SitecoreGallery"
$assets.licenseFilePath = Join-Path $assets.root "license.xml"
$assets.sitecoreVersion = "9.0.0 rev. 171002"
$assets.installerVersion = "1.0.2"
$assets.certificatesPath = Join-Path $assets.root "Certificates"
$assets.jreRequiredVersion = "1.8"
$assets.dotnetMinimumVersionValue = "394802"
$assets.dotnetMinimumVersion = "4.6.2"

$json.assets = $assets


# Settings

# Site Settings
$site = $json.settings.site
$site.prefix = "habitat"
$site.suffix = "dev.local"
$site.webroot = "C:\inetpub\wwwroot"
$site.hostName = $json.settings.site.prefix + "." + $json.settings.site.suffix
$json.settings.site = $site

$sql = $json.settings.sql
# SQL Settings
$sql.server = "."
$sql.adminUser = "sa"
$sql.adminPassword = "12345"
$sql.minimumVersion="13.0.4001"

$json.settings.sql = $sql

# XConnect Parameters
$xConnect = $json.settings.xConnect

$xConnect.ConfigurationPath = Join-Path $assets.root "xconnect-xp0.json"
$xConnect.certificateConfigurationPath = Join-Path $assets.root "xconnect-createcert.json"
$xConnect.solrConfigurationPath = Join-Path $assets.root "xconnect-solr.json"
$xConnect.packagePath = Join-Path $assets.root $("Sitecore " + $assets.sitecoreVersion + " (OnPrem)_xp0xconnect.scwdp.zip")
$xConnect.siteName = $site.prefix + "_xconnect." + $site.suffix
$xConnect.certificateName = [string]::Join(".", @($site.prefix, $site.suffix, "xConnect.Client"))
$xConnect.siteRoot = Join-Path $site.webRoot -ChildPath $xConnect.siteName
$xConnect.sqlCollectionUser = "collectionuser"
$xConnect.sqlCollectionPassword = "Test12345"

$json.settings.xConnect = $xConnect

# Sitecore Parameters
$sitecore = $json.settings.sitecore

$sitecore.solrConfigurationPath = Join-Path $assets.root "sitecore-solr.json"
$sitecore.configurationPath = Join-Path $assets.root "sitecore-xp0.json"
$sitecore.sslConfigurationPath = "$PSScriptRoot\certificates\sitecore-ssl.json"
$sitecore.packagePath = Join-Path $assets.root $("Sitecore " + $assets.sitecoreVersion +" (OnPrem)_single.scwdp.zip")
$sitecore.siteName = [string]::Join(".", @($site.prefix, $site.suffix))
$sitecore.siteRoot = Join-Path $site.webRoot -ChildPath $sitecore.siteName
$json.settings.sitecore = $sitecore
# Solr Parameters
$solr = $json.settings.solr
$solr.url = "https://localhost:8983/solr"
$solr.root = "c:\solr"
$solr.serviceName = "Solr"

Set-Content $ConfigurationFile  (ConvertTo-Json -InputObject $json -Depth 3)