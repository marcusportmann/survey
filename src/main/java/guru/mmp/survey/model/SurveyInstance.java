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

import javax.persistence.*;
import java.io.Serializable;
import java.util.UUID;

/**
 * The <code>SurveyInstance</code> class implements the Survey Instance entity, which represents
 * an instance of a survey.
 *
 * @author Marcus Portmann
 */
@Entity
@Table(schema = "SURVEY", name = "SURVEY_INSTANCES")
public class SurveyInstance
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey instance.
   */
  @Id
  @Column(name = "ID", nullable = false)
  private UUID id;

  /**
   * The survey definition this survey instance is associated with.
   */
  @SuppressWarnings("unused")
  @ManyToOne
  @JoinColumns({ @JoinColumn(name = "SURVEY_DEFINITION_ID", referencedColumnName = "ID") ,
      @JoinColumn(name = "SURVEY_DEFINITION_VERSION", referencedColumnName = "VERSION") })
  private SurveyDefinition surveyDefinition;

  /**
   * Constructs a new <code>SurveyInstance</code>.
   *
   * Default constructor required for JPA.
   */
  @SuppressWarnings("unused")
  SurveyInstance() {}

  /**
   * Constructs a new <code>SurveyInstance</code>.
   *
   * @param id                the Universally Unique Identifier (UUID) used to uniquely identify the
   *                          survey instance
   * @param surveyDefinition  the survey definition this survey instance is associated with
   */
  public SurveyInstance(UUID id, SurveyDefinition surveyDefinition)
  {
    this.id = id;
    this.surveyDefinition = surveyDefinition;
  }

  /**
   * Indicates whether some other object is "equal to" this one.
   *
   * @param obj the reference object with which to compare
   *
   * @return <code>true</code> if this object is the same as the obj argument otherwise
   *         <code>false</code>
   */
  @Override
  public boolean equals(Object obj)
  {
    if (this == obj)
    {
      return true;
    }

    if (obj == null)
    {
      return false;
    }

    if (getClass() != obj.getClass())
    {
      return false;
    }

    SurveyInstance other = (SurveyInstance) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey instance.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey instance
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the String representation of the survey instance.
   *
   * @return the String representation of the survey instance
   */
  @Override
  public String toString()
  {
    StringBuilder buffer = new StringBuilder();

    buffer.append("SurveyInstance {");
    buffer.append("id=\"").append(getId()).append("\"");
    buffer.append("}");

    return buffer.toString();
  }
}
