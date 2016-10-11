/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package guru.mmp.survey.model;

//~--- JDK imports ------------------------------------------------------------

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import java.util.UUID;

/**
 * The <code>SurveyResponse</code> class implements the Survey Response entity, which represents
 * a user's response to a survey.
 *
 * @author Marcus Portmann
 */
@Entity
@Table(schema = "SURVEY", name = "SURVEY_RESPONSES")
public class SurveyResponse
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey response.
   */
  @Id
  @Column(name = "ID", nullable = false)
  private UUID id;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey template the
   * survey response is associated with.
   */
  @Column(name = "TEMPLATE_ID", nullable = false)
  private UUID templateId;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey request the
   * survey response is associated with.
   */
  @Column(name = "REQUEST_ID")
  private UUID requestId;

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey response.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey response
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey request
   * the survey response is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey request
   *         the survey response is associated with
   */
  public UUID getRequestId()
  {
    return requestId;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey template
   * the survey response is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey template
   *         the survey response is associated with
   */
  public UUID getTemplateId()
  {
    return templateId;
  }

  /**
   * Set the Universally Unique Identifier (UUID) used to uniquely identify the survey response.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           response
   */
  public void setId(UUID id)
  {
    this.id = id;
  }

  /**
   * Set the Universally Unique Identifier (UUID) used to uniquely identify the survey request the
   * survey response is associated with.
   *
   * @param requestId the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *                  request the survey response is associated with
   */
  public void setRequestId(UUID requestId)
  {
    this.requestId = requestId;
  }

  /**
   * Set the Universally Unique Identifier (UUID) used to uniquely identify the survey template the
   * survey response is associated with.
   *
   * @param templateId the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *                   template the survey response is associated with
   */
  public void setTemplateId(UUID templateId)
  {
    this.templateId = templateId;
  }
}
