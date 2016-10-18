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
   * The name of the survey instance.
   */
  @Column(name = "NAME", nullable = false)
  private String name;

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
   * @param name              the name of the survey instance
   * @param surveyDefinition  the survey definition this survey instance is associated with
   */
  public SurveyInstance(UUID id, String name, SurveyDefinition surveyDefinition)
  {
    this.id = id;
    this.name = name;
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
   * Returns the name of the survey instance.
   *
   * @return the name of the survey instance
   */
  public String getName()
  {
    return name;
  }

  /**
   * Returns the survey definition this survey instance is associated with.
   *
   * @return the survey definition this survey instance is associated with
   */
  public SurveyDefinition getSurveyDefinition()
  {
    return surveyDefinition;
  }

  /**
   * Set the name of the survey instance.
   *
   * @param name the name of the survey instance
   */
  public void setName(String name)
  {
    this.name = name;
  }

  /**
   * Returns the String representation of the survey instance.
   *
   * @return the String representation of the survey instance
   */
  @Override
  public String toString()
  {
    return String.format("SurveyInstance {id=\"%s\", name=\"%s\"}", getId(), getName());
  }
}
