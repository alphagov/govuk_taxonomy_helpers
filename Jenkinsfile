#!/usr/bin/env groovy

library("govuk")

REPOSITORY = 'govuk_taxonomy_helpers'

node {

  try {
    stage('Checkout') {
      checkout scm
    }

    stage('Clean') {
      govuk.cleanupGit()
      govuk.mergeMasterBranch()
    }

    stage('Bundle') {
      govuk.bundleGem()
    }

    stage('Linter') {
      govuk.runRakeTask("lint")
    }

    stage('Tests') {
      govuk.runTests('spec')
    }

    if(env.BRANCH_NAME == "master") {
      stage('Publish Gem') {
        govuk.publishGem(REPOSITORY, env.BRANCH_NAME)
      }
    }

  } catch (e) {
    currentBuild.result = 'FAILED'
    step([$class: 'Mailer',
          notifyEveryUnstableBuild: true,
          recipients: 'govuk-ci-notifications@digital.cabinet-office.gov.uk',
          sendToIndividuals: true])
    throw e
  }
}
