interface JobMatch {
    jobId: number;
    matchScore: number;
    matchReasons: string[];
}
export declare class JobRecommendationService {
    static getRecommendationsForUser(userId: number): Promise<JobMatch[]>;
    private static getGeneralRecommendations;
    private static getUserProfile;
    private static calculateJobMatch;
    private static getCourseJobMatch;
    private static getSkillsMatch;
    private static getExperienceMatch;
    private static getStudentTypeMatch;
}
export {};
//# sourceMappingURL=jobRecommendationService.d.ts.map