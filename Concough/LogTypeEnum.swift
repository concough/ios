//
//  LogTypeEnum.swift
//  Concough
//
//  Created by Owner on 2017-01-30.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation

enum LogTypeEnum: String {
    case EnranceDownload = "ENTRANCE_DOWNLOAD"
    case EntranceShowNormal = "ENTRANCE_SHOW_NORMAL"
    case EntranceShowStarred = "ENTRANCE_SHOW_STARRED"
    case EntranceQuestionStar = "ENTRANCE_QUESTION_STAR"
    case EntranceQuestionUnStar = "ENTRANCE_QUESTION_UNSTAR"
    case EntranceLastVisitInfo = "ENTRANCE_LAST_VISIT_INFO"
    case EntranceCommentCreate = "ENTRANCE_COMMENT_CREATE"
    case EntranceCommentDelete = "ENTRANCE_COMMENT_DELETE"
    case EntranceLessonExamCancel = "ENTRANCE_LESSON_EXAM_CANCEL"
    case EntranceLessonExamFinished = "ENTRANCE_LESSON_EXAM_FINISHED"
}
