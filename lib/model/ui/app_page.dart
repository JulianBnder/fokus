enum AppPage {
	loadingPage, rolesPage,
	caregiverSignInPage, caregiverSignUpPage, childProfilesPage, childSignInPage,
	caregiverPanel, caregiverPlans, caregiverPlanForm, caregiverAwards, caregiverAwardForm, caregiverBadgeForm, caregiverStatistics,
	childPanel, childAwards, childAchievements, childPlanInProgress, caregiverPlanDetails, childTaskInProgress
}

extension AppPageName on AppPage {
	String get name => const {
		AppPage.loadingPage: '/loading-page',
		AppPage.rolesPage: '/roles-page',
		AppPage.caregiverSignInPage: '/auth/caregiver-sign-in-page',
		AppPage.caregiverSignUpPage: '/auth/caregiver-sign-up-page',
		AppPage.childProfilesPage: '/auth/child-profiles-page',
		AppPage.childSignInPage: '/auth/child-sign-in-page',
		AppPage.caregiverPanel: '/caregiver/panel-page',
		AppPage.caregiverPlans: '/caregiver/plans-page',
		AppPage.caregiverPlanForm: '/caregiver/plan-form-page',
		AppPage.caregiverAwards: '/caregiver/awards-page',
		AppPage.caregiverAwardForm: '/caregiver/awards-form-page',
		AppPage.caregiverBadgeForm: '/caregiver/badges-form-page',
		AppPage.caregiverStatistics: '/caregiver/statistics-page',
		AppPage.childPanel: '/child/panel-page',
		AppPage.childAwards: '/child/awards-page',
		AppPage.childAchievements: '/child/achievements-page',
		AppPage.caregiverPlanDetails: '/caregiver/plan-details',
		AppPage.childPlanInProgress: '/child/plan-in-progress-page',
		AppPage.childTaskInProgress: '/child/task-in-progress-page'
	}[this];
}

enum AppFormType { create, edit }
