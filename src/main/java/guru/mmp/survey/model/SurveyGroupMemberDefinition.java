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

//~--- non-JDK imports --------------------------------------------------------

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;

import java.io.Serializable;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyGroupMemberDefinition</code> class implements the Survey Group Member Definition
 * entity, which represents the definition of an entity who is a member of a survey group
 * definition, e.g. a member of a team, that is associated with a survey definition
 *
 * @author Marcus Portmann
 */
@JsonPropertyOrder({ "id", "name" })
public class SurveyGroupMemberDefinition
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey group member
   * definition.
   */
  @JsonProperty
  private UUID id;

  /**
   * The name of the survey group member definition.
   */
  @JsonProperty
  private String name;

  /**
   * Constructs a new <code>SurveyGroupMemberDefinition</code>.
   */
  @SuppressWarnings("unused")
  SurveyGroupMemberDefinition() {}

  /**
   * Constructs a new <code>SurveyGroupMemberDefinition</code>.
   *
   * @param id   the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *             member definition
   * @param name the name of the survey group member definition
   */
  public SurveyGroupMemberDefinition(UUID id, String name)
  {
    this.id = id;
    this.name = name;
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

    SurveyGroupMemberDefinition other = (SurveyGroupMemberDefinition) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * member definition.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *         member definition
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the name of the survey group member definition.
   *
   * @return the name of the survey group member definition
   */
  public String getName()
  {
    return name;
  }

  /**
   * Set the name of the survey group member definition.
   *
   * @param name the name of the survey group member definition
   */
  public void setName(String name)
  {
    this.name = name;
  }

  /**
   * Returns the String representation of the survey group member definition.
   *
   * @return the String representation of the survey group member definition
   */
  @Override
  public String toString()
  {
    return String.format("SurveyGroupMemberDefinition {id=\"%s\", name=\"%s\"}", getId(),
        getName());
  }
}
