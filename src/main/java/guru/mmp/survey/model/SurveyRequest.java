///*
// * Copyright 2016 Marcus Portmann
// * All rights reserved.
// *
// * Unless required by applicable law or agreed to in writing, software
// * distributed under the License is distributed on an "AS IS" BASIS,
// * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// * See the License for the specific language governing permissions and
// * limitations under the License.
// */
//
//package guru.mmp.survey.model;
//
////~--- JDK imports ------------------------------------------------------------
//
//import javax.persistence.Column;
//import javax.persistence.Entity;
//import javax.persistence.Id;
//import javax.persistence.Table;
//import java.util.UUID;
//
///**
// * The <code>SurveyRequest</code> class implements the Survey Request entity, which represents
// * a request that was sent to a person asking them to complete a survey.
// *
// * @author Marcus Portmann
// */
//@Entity
//@Table(schema = "SURVEY", name = "SURVEY_REQUESTS")
//public class SurveyRequest
//{
//  /**
//   * The Universally Unique Identifier (UUID) used to uniquely identify the survey request.
//   */
//  @Id
//  @Column(name = "ID", nullable = false)
//  private UUID id;
//
//  /**
//   * The Universally Unique Identifier (UUID) used to uniquely identify the survey definition this
//   * survey request is associated with.
//   */
//  @Column(name = "TEMPLATE_ID", nullable = false)
//  private UUID templateId;
//
//  /**
//   * Constructs a new <code>SurveyRequest</code>.
//   */
//  SurveyRequest() {}
//
//  /**
//   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey request.
//   *
//   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey request
//   */
//  public UUID getId()
//  {
//    return id;
//  }
//
//  /**
//   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey definition
//   * this survey request is associated with.
//   *
//   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey definition
//   *         this survey request is associated with
//   */
//  public UUID getTemplateId()
//  {
//    return templateId;
//  }
//
//  /**
//   * Set the Universally Unique Identifier (UUID) used to uniquely identify the survey request.
//   *
//   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey request
//   */
//  public void setId(UUID id)
//  {
//    this.id = id;
//  }
//
//  /**
//   * Set the Universally Unique Identifier (UUID) used to uniquely identify the survey definition this
//   * survey request is associated with.
//   *
//   * @param templateId the Universally Unique Identifier (UUID) used to uniquely identify the survey
//   *                   template this survey request is associated with
//   */
//  public void setTemplateId(UUID templateId)
//  {
//    this.templateId = templateId;
//  }
//}
