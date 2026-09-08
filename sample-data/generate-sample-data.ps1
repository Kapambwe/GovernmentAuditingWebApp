<#
.SYNOPSIS
    Generates all sample-data JSON files for the GovernmentAuditingWebApp.
.DESCRIPTION
    Creates wwwroot/sample-data/{country}/{institutionType}/{institutionName}/*.json
    for 10 African countries, Government (Office of Auditor General) and Private Auditors.
.EXAMPLE
    .\generate-sample-data.ps1
#>

$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot

# ── Lookup tables ─────────────────────────────────────────────────────────────

$Countries = @(
    @{ Id="zambia";       Name="Zambia";       Currency="ZMW"; Symbol="K";   GovBody="Office of the Auditor General";              GovCode="OAG-ZM" }
    @{ Id="south-africa"; Name="South Africa"; Currency="ZAR"; Symbol="R";   GovBody="Auditor General South Africa";               GovCode="AGSA"   }
    @{ Id="malawi";       Name="Malawi";       Currency="MWK"; Symbol="K";   GovBody="National Audit Office";                      GovCode="NAO-MW" }
    @{ Id="nigeria";      Name="Nigeria";      Currency="NGN"; Symbol="₦";   GovBody="Office of the Auditor-General for the Federation"; GovCode="OAGF" }
    @{ Id="kenya";        Name="Kenya";        Currency="KES"; Symbol="KSh"; GovBody="Office of the Auditor-General";              GovCode="OAG-KE" }
    @{ Id="tanzania";     Name="Tanzania";     Currency="TZS"; Symbol="TSh"; GovBody="National Audit Office of Tanzania";          GovCode="NAOT"   }
    @{ Id="uganda";       Name="Uganda";       Currency="UGX"; Symbol="USh"; GovBody="Office of the Auditor General";              GovCode="OAG-UG" }
    @{ Id="botswana";     Name="Botswana";     Currency="BWP"; Symbol="P";   GovBody="Office of the Auditor General";              GovCode="OAG-BW" }
    @{ Id="namibia";      Name="Namibia";      Currency="NAD"; Symbol="N$";  GovBody="Office of the Auditor-General";              GovCode="OAG-NA" }
    @{ Id="ghana";        Name="Ghana";        Currency="GHS"; Symbol="GH₵"; GovBody="Ghana Audit Service";                       GovCode="GAS"    }
)

$PrivateFirms = @(
    @{ Id="kpmg";                    Name="KPMG";                    Type="Big Four";      Founded=1987; Staff=350 }
    @{ Id="pricewaterhousecoopers";  Name="PricewaterhouseCoopers";  Type="Big Four";      Founded=1998; Staff=420 }
    @{ Id="deloitte";                Name="Deloitte";                Type="Big Four";      Founded=1993; Staff=480 }
    @{ Id="ernst-young";             Name="Ernst & Young";           Type="Big Four";      Founded=1989; Staff=310 }
    @{ Id="grant-thornton";          Name="Grant Thornton";          Type="Mid-Tier";      Founded=2001; Staff=180 }
    @{ Id="bdo";                     Name="BDO";                     Type="Mid-Tier";      Founded=2003; Staff=140 }
    @{ Id="mazars";                  Name="Mazars";                  Type="Mid-Tier";      Founded=2005; Staff=120 }
    @{ Id="moore-africa";            Name="Moore Africa";            Type="Regional";      Founded=2010; Staff=90  }
)

$AuditTypes   = @("Financial", "Compliance", "Performance", "Forensic", "IT", "Operational")
$AuditStatus  = @("Completed", "In Progress", "Draft", "Under Review", "Pending Clearance")
$RiskLevels   = @("Low", "Medium", "High", "Critical")
$Ministries = @(
    "Ministry of Finance",
    "Ministry of Health",
    "Ministry of Education",
    "Ministry of Works and Infrastructure",
    "Ministry of Agriculture",
    "Ministry of Energy",
    "Ministry of Justice",
    "Ministry of Local Government",
    "Ministry of Home Affairs",
    "Department of Social Welfare"
)

# ── Helpers ───────────────────────────────────────────────────────────────────

function New-Dir { param($p) if (-not (Test-Path $p)) { New-Item -Path $p -ItemType Directory | Out-Null } }
function Out-Json { param($p, $obj) $obj | ConvertTo-Json -Depth 10 | Set-Content -Path $p -Encoding utf8 }
function Get-Rand { param($min, $max) Get-Random -Minimum $min -Maximum $max }
function Pick { param($arr) $arr[(Get-Random -Maximum $arr.Count)] }
function FY { param($offset=0) $y = 2024 - $offset; "$y/$($y+1)" }
function DateStr { param($y=2024, $mMin=1, $mMax=12) "$y-$('{0:D2}' -f (Get-Random -Min $mMin -Max $mMax))-$('{0:D2}' -f (Get-Random -Min 1 -Max 28))" }

# ── File generators ───────────────────────────────────────────────────────────

function New-GovInstitutionProfile {
    param($country, $dir)
    Out-Json "$dir/institution-profile.json" @{
        institutionId   = "$($country.GovCode)-001"
        institutionName = $country.GovBody
        country         = $country.Name
        institutionType = "Government"
        mandate         = "Constitutional mandate to audit all public accounts and report to the National Assembly"
        established     = (Get-Rand 1950 1980)
        headquarters    = "$($country.Name) Capital"
        staffStrength   = (Get-Rand 280 1200)
        annualBudget    = (Get-Rand 8000000 85000000)
        currency        = $country.Currency
        currencySymbol  = $country.Symbol
        legalFramework  = "Public Audit Act"
        auditStandards  = @("ISSAI", "INTOSAI", "IPSAS")
        contactEmail    = "info@auditor-general.$($country.Id).gov"
        website         = "https://www.auditorgeneral.$($country.Id).gov"
        socialMedia     = @{
            twitter  = "@AuditorGeneral$($country.Name -replace ' ','')"
            linkedin = "auditor-general-$($country.Id)"
        }
    }
}

function New-GovAuditEngagements {
    param($country, $dir)
    $engagements = @()
    for ($i = 1; $i -le 20; $i++) {
        $fy     = FY (Get-Rand 0 3)
        $type   = Pick $AuditTypes
        $status = Pick $AuditStatus
        $ministry = Pick $Ministries
        $engagements += @{
            engagementId    = "$($country.GovCode)-ENG-$('{0:D3}' -f $i)"
            auditType       = $type
            auditedEntity   = $ministry
            fiscalYear      = $fy
            startDate       = DateStr 2024 1 6
            endDate         = DateStr 2024 7 12
            leadAuditor     = "Senior Auditor $i"
            teamSize        = (Get-Rand 3 12)
            status          = $status
            riskRating      = Pick $RiskLevels
            budgetAllocated = (Get-Rand 50000 800000)
            actualCost      = (Get-Rand 40000 750000)
            currency        = $country.Currency
            findingsCount   = (Get-Rand 2 18)
            reportIssued    = ($status -eq "Completed")
            managementResponse = ($status -in @("Completed","Under Review"))
        }
    }
    Out-Json "$dir/audit-engagements.json" $engagements
}

function New-GovAuditFindings {
    param($country, $dir)
    $categories = @("Revenue Shortfall","Unsupported Payments","Asset Misappropriation","Procurement Irregularity","Payroll Fraud","Non-compliance","IT Control Weakness","Unauthorized Expenditure","Unretired Imprest","Missing Documentation")
    $findings = @()
    for ($i = 1; $i -le 25; $i++) {
        $cat = Pick $categories
        $findings += @{
            findingId       = "$($country.GovCode)-FND-$('{0:D3}' -f $i)"
            category        = $cat
            ministry        = Pick $Ministries
            fiscalYear      = FY (Get-Rand 0 2)
            severity        = Pick $RiskLevels
            amountInvolved  = (Get-Rand 100000 50000000)
            currency        = $country.Currency
            description     = "$cat identified during audit of expenditures for fiscal year $(FY (Get-Rand 0 2))"
            recommendation  = "Management should implement controls to prevent recurrence of $($cat.ToLower())"
            managementResponse = Pick @("Accepted","Partially Accepted","Disputed","Pending")
            implementationStatus = Pick @("Implemented","In Progress","Not Started","Overdue")
            targetDate      = DateStr 2025 1 12
            auditorComment  = "Finding escalated for follow-up"
            reportReference = "$($country.GovCode)-RPT-$('{0:D3}' -f (Get-Rand 1 20))"
        }
    }
    Out-Json "$dir/audit-findings.json" $findings
}

function New-GovRevenueAudits {
    param($country, $dir)
    $audits = @()
    for ($i = 1; $i -le 10; $i++) {
        $budgeted = Get-Rand 5000000 200000000
        $actual   = [int]($budgeted * (Get-Rand 60 98) / 100)
        $shortfall = $budgeted - $actual
        $audits += @{
            auditId             = "$($country.GovCode)-REV-$('{0:D3}' -f $i)"
            institutionName     = Pick $Ministries
            fiscalYear          = FY (Get-Rand 0 2)
            currency            = $country.Currency
            budgetedRevenue     = $budgeted
            actualRevenue       = $actual
            revenueShortfall    = $shortfall
            shortfallPercentage = [math]::Round(($shortfall / $budgeted) * 100, 1)
            unbankedAmount      = (Get-Rand 50000 5000000)
            revenueLeakage      = (Get-Rand 10000 2000000)
            uncollectedRevenue  = (Get-Rand 100000 8000000)
            invalidWaivers      = (Get-Rand 0 20)
            status              = Pick $AuditStatus
            riskRating          = Pick $RiskLevels
        }
    }
    Out-Json "$dir/revenue-audits.json" $audits
}

function New-GovExpenditureAudits {
    param($country, $dir)
    $audits = @()
    for ($i = 1; $i -le 10; $i++) {
        $total = Get-Rand 10000000 500000000
        $audits += @{
            auditId                      = "$($country.GovCode)-EXP-$('{0:D3}' -f $i)"
            institutionName              = Pick $Ministries
            fiscalYear                   = FY (Get-Rand 0 2)
            currency                     = $country.Currency
            totalExpenditure             = $total
            unsupportedPayments          = (Get-Rand 50000 8000000)
            unretiredImprest             = (Get-Rand 10000 3000000)
            paymentsWithoutZRAClearance  = (Get-Rand 0 2000000)
            unauthorizedExpenditures     = (Get-Rand 0 5000000)
            duplicatePayments            = (Get-Rand 0 1000000)
            contractVariationsExceedingThreshold = (Get-Rand 0 4000000)
            status                       = Pick $AuditStatus
            riskRating                   = Pick $RiskLevels
        }
    }
    Out-Json "$dir/expenditure-audits.json" $audits
}

function New-GovAssetAudits {
    param($country, $dir)
    $audits = @()
    for ($i = 1; $i -le 10; $i++) {
        $total    = Get-Rand 200 2000
        $verified = [int]($total * (Get-Rand 70 98) / 100)
        $missing  = $total - $verified
        $audits += @{
            auditId                    = "$($country.GovCode)-AST-$('{0:D3}' -f $i)"
            institutionName            = Pick $Ministries
            fiscalYear                 = FY (Get-Rand 0 2)
            currency                   = $country.Currency
            totalAssetsInRegister      = $total
            assetsPhysicallyVerified   = $verified
            missingAssets              = $missing
            valueOfMissingAssets       = (Get-Rand 100000 20000000)
            propertiesWithoutTitleDeeds = (Get-Rand 0 50)
            assetsNotInsured           = (Get-Rand 0 100)
            disposedWithoutAuthority   = (Get-Rand 0 10)
            status                     = Pick $AuditStatus
            riskRating                 = Pick $RiskLevels
        }
    }
    Out-Json "$dir/asset-audits.json" $audits
}

function New-GovHRAudits {
    param($country, $dir)
    $audits = @()
    for ($i = 1; $i -le 10; $i++) {
        $approved = Get-Rand 100 3000
        $actual   = [int]($approved * (Get-Rand 95 130) / 100)
        $over     = [math]::Max(0, $actual - $approved)
        $audits += @{
            auditId                = "$($country.GovCode)-HR-$('{0:D3}' -f $i)"
            institutionName        = Pick $Ministries
            fiscalYear             = FY (Get-Rand 0 2)
            currency               = $country.Currency
            approvedEstablishment  = $approved
            actualStaffCount       = $actual
            overEmployment         = $over
            costOfOverEmployment   = ($over * (Get-Rand 3000 15000))
            unauthorizedPositions  = (Get-Rand 0 25)
            ghostWorkers           = (Get-Rand 0 10)
            missingPersonnelFiles  = (Get-Rand 0 80)
            staffWithoutContracts  = (Get-Rand 0 40)
            status                 = Pick $AuditStatus
            riskRating             = Pick $RiskLevels
        }
    }
    Out-Json "$dir/hr-audits.json" $audits
}

function New-GovLiabilityAudits {
    param($country, $dir)
    $audits = @()
    for ($i = 1; $i -le 10; $i++) {
        $napsa = Get-Rand 0 5000000
        $nhima = Get-Rand 0 2000000
        $paye  = Get-Rand 0 8000000
        $tevet = Get-Rand 0 1000000
        $audits += @{
            auditId               = "$($country.GovCode)-LIB-$('{0:D3}' -f $i)"
            institutionName       = Pick $Ministries
            fiscalYear            = FY (Get-Rand 0 2)
            currency              = $country.Currency
            napsaArrears          = $napsa
            nhimaArrears          = $nhima
            payeArrears           = $paye
            tevetArrears          = $tevet
            totalStatutoryArrears = ($napsa + $nhima + $paye + $tevet)
            pensionArrears        = (Get-Rand 0 3000000)
            loanRepaymentArrears  = (Get-Rand 0 2000000)
            status                = Pick $AuditStatus
            riskRating            = Pick $RiskLevels
        }
    }
    Out-Json "$dir/liability-audits.json" $audits
}

function New-GovGrantAudits {
    param($country, $dir)
    $audits = @()
    for ($i = 1; $i -le 10; $i++) {
        $allocated = Get-Rand 500000 50000000
        $received  = [int]($allocated * (Get-Rand 70 100) / 100)
        $utilized  = [int]($received  * (Get-Rand 40 95) / 100)
        $unutilized = $received - $utilized
        $utilRate  = if ($received -gt 0) { [math]::Round(($utilized / $received) * 100, 1) } else { 0 }
        $audits += @{
            auditId              = "$($country.GovCode)-GRT-$('{0:D3}' -f $i)"
            institutionName      = Pick $Ministries
            fiscalYear           = FY (Get-Rand 0 2)
            currency             = $country.Currency
            totalGrantsAllocated = $allocated
            totalGrantsReceived  = $received
            totalGrantsUtilized  = $utilized
            unutilizedGrants     = $unutilized
            utilizationRate      = $utilRate
            unretiredGrants      = (Get-Rand 0 3000000)
            grantsWithoutReports = (Get-Rand 0 10)
            status               = Pick $AuditStatus
            riskRating           = Pick $RiskLevels
        }
    }
    Out-Json "$dir/grant-audits.json" $audits
}

function New-GovFireAudits {
    param($country, $dir)
    $audits = @()
    $councils = @("City Council","Municipal Council","District Council","Town Council","Urban District Council")
    for ($i = 1; $i -le 10; $i++) {
        $total     = Get-Rand 30 500
        $insured   = [int]($total * (Get-Rand 50 100) / 100)
        $hasStation = (Get-Random -Maximum 10) -gt 2
        $stations  = if ($hasStation) { Get-Rand 1 8 } else { 0 }
        $audits += @{
            auditId              = "$($country.GovCode)-FIRE-$('{0:D3}' -f $i)"
            institutionName      = "$(Pick $councils) - $($country.Name)"
            fiscalYear           = FY (Get-Rand 0 2)
            currency             = $country.Currency
            hasFireStation       = $hasStation
            numberOfFireStations = $stations
            populationCoverage   = [math]::Round((Get-Rand 10 95) + (Get-Random), 1)
            totalFirefighters    = $total
            insuredFirefighters  = $insured
            fireVehicles         = (Get-Rand 1 20)
            functionalVehicles   = (Get-Rand 1 15)
            status               = Pick $AuditStatus
            riskRating           = Pick $RiskLevels
        }
    }
    Out-Json "$dir/fire-services-audits.json" $audits
}

function New-GovAnnualReport {
    param($country, $dir)
    Out-Json "$dir/annual-report-summary.json" @{
        reportTitle         = "Annual Report of the $($country.GovBody) - $( FY 0 )"
        country             = $country.Name
        fiscalYear          = FY 0
        totalAuditsCompleted = (Get-Rand 80 400)
        totalFindingsIssued  = (Get-Rand 200 1500)
        totalAmountQuestioned = (Get-Rand 500000000 5000000000)
        totalAmountRecovered  = (Get-Rand 10000000 200000000)
        currency             = $country.Currency
        currencySymbol       = $country.Symbol
        auditCoverage        = "$( Get-Rand 70 98 )%"
        keyHighlights        = @(
            "Increased audit coverage to $(Get-Rand 80 98)% of public accounts"
            "Recovered $($country.Symbol)$(Get-Rand 10 200) million through follow-up actions"
            "$(Get-Rand 5 25) matters referred to Anti-Corruption Commission"
            "Issued $(Get-Rand 50 200) special audit reports on request"
        )
        auditsByType = @{
            financial   = (Get-Rand 40 200)
            compliance  = (Get-Rand 30 150)
            performance = (Get-Rand 10 80)
            forensic    = (Get-Rand 5 40)
            it          = (Get-Rand 3 20)
        }
        complianceRate       = "$( Get-Rand 45 75 )%"
        publishedDate        = DateStr 2025 1 6
    }
}

function New-PrivateInstitutionProfile {
    param($country, $firm, $dir)
    Out-Json "$dir/institution-profile.json" @{
        institutionId    = "$($firm.Id)-$($country.Id)-001"
        institutionName  = "$($firm.Name) $($country.Name)"
        parentFirm       = $firm.Name
        country          = $country.Name
        institutionType  = "Private Auditor"
        firmType         = $firm.Type
        founded          = ($firm.Founded + (Get-Rand 0 5))
        staffCount       = (Get-Rand 60 500)
        partners         = (Get-Rand 4 30)
        currency         = $country.Currency
        currencySymbol   = $country.Symbol
        annualRevenue    = (Get-Rand 2000000 80000000)
        headquarters     = "$($country.Name) Capital"
        officeLocations  = (Get-Rand 2 8)
        certifications   = @("ICPAZ","ACCA","CPA","ICPAK","ICAN","ICAG","ICPAU")
        serviceLines     = @("External Audit","Internal Audit","Tax Advisory","Risk Advisory","Forensic","IT Audit","Sustainability Reporting")
        auditStandards   = @("IFRS","ISA","IPSAS","King IV")
        contactEmail     = "info@$($firm.Id).$($country.Id)"
        website          = "https://www.$($firm.Id).com/$($country.Id)"
        regulatoryBody   = "Institute of Chartered Accountants"
        licenseNumber    = "AUD-$(Get-Rand 10000 99999)"
    }
}

function New-PrivateAuditEngagements {
    param($country, $firm, $dir)
    $clientTypes = @("Parastatal","Listed Company","NGO","Commercial Bank","Insurance Company","Pension Fund","Mining Company","Telecommunications","Healthcare","Retail Group")
    $engagements = @()
    for ($i = 1; $i -le 15; $i++) {
        $type   = Pick $AuditTypes
        $status = Pick $AuditStatus
        $engagements += @{
            engagementId    = "$($firm.Id)-$($country.Id)-ENG-$('{0:D3}' -f $i)"
            clientName      = "$(Pick $clientTypes) $($country.Name) Ltd"
            clientType      = Pick $clientTypes
            auditType       = $type
            fiscalYear      = FY (Get-Rand 0 2)
            startDate       = DateStr 2024 1 6
            endDate         = DateStr 2024 7 12
            engagementPartner = "Partner $i"
            teamSize        = (Get-Rand 3 10)
            status          = $status
            riskRating      = Pick $RiskLevels
            feesBilled      = (Get-Rand 80000 3000000)
            feesCollected   = (Get-Rand 60000 2800000)
            currency        = $country.Currency
            reportType      = Pick @("Unqualified","Qualified","Adverse","Disclaimer")
            auditOpinion    = Pick @("Clean","Modified","Emphasis of Matter","Qualified")
            managementLetterIssued = ($status -eq "Completed")
        }
    }
    Out-Json "$dir/audit-engagements.json" $engagements
}

function New-PrivateAuditFindings {
    param($country, $firm, $dir)
    $categories = @("Internal Control Weakness","Going Concern","Related Party Transaction","Revenue Recognition","Inventory Valuation","Fixed Asset Overstatement","Tax Non-compliance","Fraud Risk","IT Vulnerability","Regulatory Breach")
    $findings = @()
    for ($i = 1; $i -le 20; $i++) {
        $cat = Pick $categories
        $findings += @{
            findingId        = "$($firm.Id)-$($country.Id)-FND-$('{0:D3}' -f $i)"
            category         = $cat
            clientName       = "Client $($country.Id) $i Ltd"
            fiscalYear       = FY (Get-Rand 0 2)
            severity         = Pick $RiskLevels
            amountInvolved   = (Get-Rand 50000 20000000)
            currency         = $country.Currency
            description      = "$cat identified in the audit of client financial statements for $(FY (Get-Rand 0 2))"
            recommendation   = "Implement enhanced controls to address $($cat.ToLower())"
            managementResponse = Pick @("Accepted","Partially Accepted","Disputed","Pending")
            implementationStatus = Pick @("Implemented","In Progress","Not Started","Overdue")
            targetDate       = DateStr 2025 1 12
            reportedToBoard  = ($true,$false | Get-Random)
        }
    }
    Out-Json "$dir/audit-findings.json" $findings
}

function New-PrivateClientPortfolio {
    param($country, $firm, $dir)
    $sectors = @("Banking","Insurance","Mining","Telecommunications","Retail","Manufacturing","Agriculture","Real Estate","Healthcare","Government")
    $clients = @()
    for ($i = 1; $i -le 20; $i++) {
        $sector = Pick $sectors
        $clients += @{
            clientId        = "$($firm.Id)-$($country.Id)-CLI-$('{0:D3}' -f $i)"
            clientName      = "$sector $($country.Name) $(Pick @('Ltd','PLC','Corp','Holdings','Group'))"
            sector          = $sector
            clientSince     = (Get-Rand 2005 2022)
            annualFee       = (Get-Rand 50000 5000000)
            currency        = $country.Currency
            auditType       = Pick $AuditTypes
            engagementStatus = Pick $AuditStatus
            riskProfile     = Pick $RiskLevels
            regulatedEntity = (Get-Random -Maximum 2) -eq 1
            listedCompany   = (Get-Random -Maximum 4) -eq 1
        }
    }
    Out-Json "$dir/client-portfolio.json" $clients
}

function New-PrivateFinancialPerformance {
    param($country, $firm, $dir)
    $years = @()
    for ($y = 2021; $y -le 2024; $y++) {
        $revenue = Get-Rand 3000000 80000000
        $cost    = [int]($revenue * (Get-Rand 55 75) / 100)
        $profit  = $revenue - $cost
        $years += @{
            year            = $y
            totalRevenue    = $revenue
            auditFees       = [int]($revenue * 0.6)
            advisoryFees    = [int]($revenue * 0.25)
            taxFees         = [int]($revenue * 0.15)
            totalCosts      = $cost
            operatingProfit = $profit
            profitMargin    = [math]::Round(($profit / $revenue) * 100, 1)
            currency        = $country.Currency
            headcount       = (Get-Rand 60 500)
            newClients      = (Get-Rand 5 30)
            retainedClients = (Get-Rand 40 120)
            churned         = (Get-Rand 1 8)
        }
    }
    Out-Json "$dir/financial-performance.json" $years
}

function New-PrivateComplianceRecord {
    param($country, $firm, $dir)
    Out-Json "$dir/regulatory-compliance.json" @{
        firmId             = "$($firm.Id)-$($country.Id)"
        firmName           = "$($firm.Name) $($country.Name)"
        country            = $country.Name
        regulatoryBody     = "Institute of Chartered Accountants of $($country.Name)"
        licenseStatus      = "Active"
        licenseExpiry      = "$(Get-Rand 2026 2028)-12-31"
        peerReviewStatus   = Pick @("Passed","Passed with Observations","Pending","Scheduled")
        lastPeerReview     = DateStr 2023 1 12
        nextPeerReview     = DateStr 2026 1 12
        qualityControlRating = Pick @("Satisfactory","Needs Improvement","Unsatisfactory")
        disciplinaryActions = (Get-Rand 0 2)
        finesIssued        = (Get-Rand 0 3)
        cpd_hoursCompliance = "$( Get-Rand 80 100 )%"
        independenceBreaches = (Get-Rand 0 1)
        auditCommitteeEngagements = (Get-Rand 10 60)
        regulatoryFilingsCurrent = $true
        lastInspectionDate = DateStr 2024 1 6
        inspectionResult   = Pick @("Satisfactory","Minor Issues","Major Issues")
    }
}

# ── Permission sets by institution type ──────────────────────────────────────

$PermSets = @{

    # Full constitutional mandate — all permissions
    Government = @(
        "Dashboards.ViewMain"
        "Dashboards.ViewPublicFinance"
        "Dashboards.ViewReports"
        "AuditManagement.ViewRegistry"
        "AuditManagement.ManageAuditees"
        "AuditManagement.ReviewQuality"
        "AuditManagement.ViewReports"
        "AuditManagement.TrackTime"
        "StrategicPlanning.ViewAnnualPlan"
        "StrategicPlanning.ViewAuditUniverse"
        "StrategicPlanning.ManageDocuments"
        "StrategicPlanning.UseSamplingTools"
        "ParliamentaryInterface.ViewRequests"
        "ParliamentaryInterface.ManageAppearances"
        "ParliamentaryInterface.ViewPACRecommendations"
        "ParliamentaryInterface.ManageCorrespondence"
        "RealTimeAudit.MonitorFinancials"
        "RealTimeAudit.MonitorControls"
        "RealTimeAudit.MonitorProcurement"
        "RealTimeAudit.MonitorAssets"
        "RealTimeAudit.MonitorOrganizations"
        "DecisionIntelligence.ViewDashboard"
        "DecisionIntelligence.AssessRisk"
        "DecisionIntelligence.InvestigateFraud"
        "DecisionIntelligence.ManageRules"
        "AdvancedFeatures.ManageContractAudit"
        "AdvancedFeatures.ManageGovernance"
        "AdvancedFeatures.ViewPerformance"
        "AIAssistant.UseAssistant"
        "System.ManageUsers"
        "System.ConfigureSettings"
    )

    # Big Four: broad access; no parliamentary or system admin
    BigFour = @(
        "Dashboards.ViewMain"
        "Dashboards.ViewReports"
        "AuditManagement.ViewRegistry"
        "AuditManagement.ReviewQuality"
        "AuditManagement.ViewReports"
        "AuditManagement.TrackTime"
        "StrategicPlanning.ViewAnnualPlan"
        "StrategicPlanning.ViewAuditUniverse"
        "StrategicPlanning.ManageDocuments"
        "StrategicPlanning.UseSamplingTools"
        "RealTimeAudit.MonitorFinancials"
        "RealTimeAudit.MonitorControls"
        "RealTimeAudit.MonitorProcurement"
        "RealTimeAudit.MonitorAssets"
        "DecisionIntelligence.ViewDashboard"
        "DecisionIntelligence.AssessRisk"
        "DecisionIntelligence.InvestigateFraud"
        "AdvancedFeatures.ManageContractAudit"
        "AdvancedFeatures.ViewPerformance"
        "AIAssistant.UseAssistant"
    )

    # Mid-tier: core audit access; no forensic investigation or real-time procurement
    MidTier = @(
        "Dashboards.ViewMain"
        "Dashboards.ViewReports"
        "AuditManagement.ViewRegistry"
        "AuditManagement.ReviewQuality"
        "AuditManagement.ViewReports"
        "AuditManagement.TrackTime"
        "StrategicPlanning.ViewAnnualPlan"
        "StrategicPlanning.ManageDocuments"
        "RealTimeAudit.MonitorFinancials"
        "RealTimeAudit.MonitorControls"
        "DecisionIntelligence.ViewDashboard"
        "DecisionIntelligence.AssessRisk"
        "AdvancedFeatures.ViewPerformance"
        "AIAssistant.UseAssistant"
    )

    # Regional: read-only dashboards + standard audit reports
    Regional = @(
        "Dashboards.ViewMain"
        "Dashboards.ViewReports"
        "AuditManagement.ViewRegistry"
        "AuditManagement.ViewReports"
        "AuditManagement.TrackTime"
        "StrategicPlanning.ViewAnnualPlan"
        "RealTimeAudit.MonitorFinancials"
        "DecisionIntelligence.ViewDashboard"
        "AdvancedFeatures.ViewPerformance"
    )
}

$FirmPermSet = @{
    "kpmg"                   = "BigFour"
    "pricewaterhousecoopers" = "BigFour"
    "deloitte"               = "BigFour"
    "ernst-young"            = "BigFour"
    "grant-thornton"         = "MidTier"
    "bdo"                    = "MidTier"
    "mazars"                 = "MidTier"
    "moore-africa"           = "Regional"
}

function New-GovAuthComponent {
    param($country, $dir)
    Out-Json "$dir/authcomponent.json" @(
        @{
            componentId     = "$($country.GovCode)-AUTH-001"
            institutionId   = $country.GovCode
            institutionName = $country.GovBody
            country         = $country.Name
            componentName   = "$($country.GovBody) Audit Portal"
            componentType   = "WebPortal"
            institutionType = "Government"
            isActive        = $true
            permissions     = $PermSets["Government"]
            description     = "Full-access portal for constitutional audit mandate - $($country.GovBody)"
        }
    )
}

function New-PrivateAuthComponent {
    param($country, $firm, $dir)
    $setKey = $FirmPermSet[$firm.Id]
    $perms  = $PermSets[$setKey]
    Out-Json "$dir/authcomponent.json" @(
        @{
            componentId     = "$($firm.Id)-$($country.Id)-AUTH-001"
            institutionId   = "$($firm.Id)-$($country.Id)"
            institutionName = "$($firm.Name) $($country.Name)"
            country         = $country.Name
            componentName   = "$($firm.Name) $($country.Name) Audit Portal"
            componentType   = "WebPortal"
            institutionType = "Private Auditor"
            firmType        = $firm.Type
            permissionTier  = $setKey
            isActive        = $true
            permissions     = $perms
            description     = "$($firm.Type) auditing portal for $($firm.Name) $($country.Name) - $($perms.Count) permissions"
        }
    )
}

# ── Main generation loop ──────────────────────────────────────────────────────

$total = 0
$start = Get-Date

Write-Host ""
Write-Host "Generating GovernmentAuditingWebApp sample data..." -ForegroundColor Cyan
Write-Host "Root: $Root" -ForegroundColor DarkGray
Write-Host ""

foreach ($country in $Countries) {
    Write-Host "  $($country.Name)" -ForegroundColor Yellow

    # ── Government ──────────────────────────────────────────────────────────
    $govDir = Join-Path $Root "$($country.Id)/government/office-of-auditor-general"
    New-Dir $govDir

    New-GovInstitutionProfile  -country $country -dir $govDir; $total++
    New-GovAuditEngagements    -country $country -dir $govDir; $total++
    New-GovAuditFindings       -country $country -dir $govDir; $total++
    New-GovRevenueAudits       -country $country -dir $govDir; $total++
    New-GovExpenditureAudits   -country $country -dir $govDir; $total++
    New-GovAssetAudits         -country $country -dir $govDir; $total++
    New-GovHRAudits            -country $country -dir $govDir; $total++
    New-GovLiabilityAudits     -country $country -dir $govDir; $total++
    New-GovGrantAudits         -country $country -dir $govDir; $total++
    New-GovFireAudits          -country $country -dir $govDir; $total++
    New-GovAnnualReport        -country $country -dir $govDir; $total++
    New-GovAuthComponent       -country $country -dir $govDir; $total++

    Write-Host "    [Gov]  $($country.GovBody) - 12 files" -ForegroundColor Green

    # ── Private Auditors ────────────────────────────────────────────────────
    foreach ($firm in $PrivateFirms) {
        $firmDir = Join-Path $Root "$($country.Id)/private-auditors/$($firm.Id)"
        New-Dir $firmDir

        New-PrivateInstitutionProfile -country $country -firm $firm -dir $firmDir; $total++
        New-PrivateAuditEngagements   -country $country -firm $firm -dir $firmDir; $total++
        New-PrivateAuditFindings      -country $country -firm $firm -dir $firmDir; $total++
        New-PrivateClientPortfolio    -country $country -firm $firm -dir $firmDir; $total++
        New-PrivateFinancialPerformance -country $country -firm $firm -dir $firmDir; $total++
        New-PrivateComplianceRecord   -country $country -firm $firm -dir $firmDir; $total++
        New-PrivateAuthComponent      -country $country -firm $firm -dir $firmDir; $total++

        Write-Host "    [Prv]  $($firm.Name) - 7 files" -ForegroundColor DarkGreen
    }
}

$elapsed = [math]::Round(((Get-Date) - $start).TotalSeconds, 1)
Write-Host ""
Write-Host "  Done! $total files generated in $elapsed s" -ForegroundColor Magenta
Write-Host "  Path: $Root" -ForegroundColor DarkGray
Write-Host ""
